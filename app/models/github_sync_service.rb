class GithubSyncService
  # Initializes the GitHub sync service by passing the repo and token
  def initialize(repo:, token:)
    @repo_name = repo
    @octokit_client = Octokit::Client.new(access_token: token)
  end

  # Syncs the github issues with authors
  #
  # - Creates issues for authors that don't have a github issue number in the model (and updates their github issue number)
  # - Updates existing authors with github issue numbers from the github issue info (only if there were modifications)
  # - Deletes authors with github issue numbers if the github issue doesn't exist anymore
  # - Creates authors in the database for github issues that don't have a matching author (and creates a self-published book for the author)
  def sync
    get_github_issues
    update_authors_synced_with_issue
    delete_authors_synced_with_no_issue
    create_issues_for_authors_not_yet_synced
    create_authors_for_issues_not_yet_synced
  rescue => err
    Rails.logger.error "Aborting synchronization"
    Rails.logger.error "There was an error syncing with GitHub"
    raise err
  end

  # Syncs the database from a received github event.
  #
  # This method is idempotent, in the sense that an event can be processed multiple times and it won't have unintended
  # side effects.
  #
  # Valid events are:
  # - create: Creates a new author with book from the issue information. If there is already an author with that issue
  #   number, it updates the existing author
  # - update: Updates an existing author with book from the issue information. If the author doesn't exist create it
  # - delete: Deletes an existing author with the issue number. If there are no authors with that issue number does nothing
  def sync_from_event event
    action = event["action"]
    github_issue = event["issue"]
    issue_number = github_issue["number"]
    author = Author.find_by_gh_issue_number(issue_number)
    case action
    when "edited"
      update_or_create_author_from_github(author, github_issue)
    when "opened"
      create_or_update_author_from_github(author, github_issue)
    when "deleted"
      delete_author(author, github_issue["number"])
    else
      Rails.logger.warn "Unhandled event action '#{action}' received from GitHub event"
    end
  end

  private

  attr_reader :github_issues, :repo_name, :octokit_client

  # Fetches the github issues from the repo and creates a hash with all the issues using the issue_number as key
  def get_github_issues
    @github_issues = octokit_client.issues(repo_name).each_with_object({}) { |issue, issues|
      issues[issue["number"]] = issue
    }
  end

  # This method takes the authors that are both in the database and in github, and updates the author name and
  # description if needed
  def update_authors_synced_with_issue
    authors_to_update = authors_synced.select { |author| issue_numbers.include?(author.gh_issue_number) }
    authors_to_update.each do |author|
      github_issue = github_issue_for author
      if author_is_up_to_date(author, github_issue)
        Rails.logger.info "Author #{author.id} is up to date, no need to update it"
      else
        update_author_from_github(author, github_issue)
      end
    end
  end

  # Pulls from the model the authors that already have an issue number
  def authors_synced
    Author.where.not(gh_issue_number: nil)
  end

  # Returns only the issue numbers already fetched from github
  def issue_numbers
    github_issues.keys
  end

  # helper method that returns whether an author is up to date with regards to its github issue
  def author_is_up_to_date(author, github_issue)
    author.name == github_issue["title"] && author.bio == github_issue["body"]
  end

  # Returns the github issue for a giving author
  def github_issue_for(author)
    github_issues[author.gh_issue_number]
  end

  # This method updates an author in the database from the github issue information
  def update_author_from_github(author, github_issue)
    Rails.logger.info "Updating author #{author.id} from changed GitHub information"
    unless author.update(name: github_issue["title"], bio: github_issue["body"], gh_last_sync: Time.now)
      Rails.logger.warn "There was an error updating #{author.id} from changed GitHub information"
    end
  end

  # This method takes the authors that are in the database but have no corresponding issues in github. These are
  # authors that where synced at some point but later deleted from github and for some reason the webhook failed
  def delete_authors_synced_with_no_issue
    authors_to_delete = authors_synced.select { |author| issue_numbers.exclude?(author.gh_issue_number) }
    authors_to_delete.each do |author|
      delete_author(author, author.gh_issue_number)
    end
  end

  # Deletes an author, optionally receives an issue number to emit an error message in case the author passed is nil
  def delete_author(author, issue_number = nil)
    if author
      Rails.logger.info "Deleting author #{author.id} from database because issue #{author.gh_issue_number} is no longer in the repo"
      unless author.destroy
        Rails.logger.warn "There was an error deleting #{author.id}"
      end
    else
      Rails.logger.warn "Trying to delete an author for issue ##{issue_number} that doesn't exist in the database. Ignoring"
    end
  end

  def create_issues_for_authors_not_yet_synced
    authors_not_yet_synced.each do |author|
      issue = create_github_issue_for author
      unless author.update(gh_issue_number: issue["number"], gh_last_sync: Time.now)
        Rails.logger.warn "There was an error updating author #{author.id} with the github issue information. Proceeding anyway"
      end
    end
  end

  # Pulls from the database the authors that have not yet been synced (have a null github issue number)
  def authors_not_yet_synced
    Author.where(gh_issue_number: nil)
  end

  # Creates a GitHub issue with the title using the author name and the body using the author bio
  def create_github_issue_for(author)
    Rails.logger.info "Creating github issue for author #{author.id}"
    octokit_client.create_issue(repo_name, author.name, author.bio)
  end

  # All of the issues that don't have a corresponding author in the database create an author
  def create_authors_for_issues_not_yet_synced
    existing_issues = Author.all.map(&:gh_issue_number)
    new_issues = issue_numbers.select { |issue_number| existing_issues.exclude?(issue_number) }
    new_issues.each do |issue_number|
      create_author_for github_issues[issue_number]
    end
  end

  # Creates an author in the database from a github issue
  def create_author_for(issue)
    Rails.logger.info "Creating an author for GitHub issue ##{issue["number"]}"
    author = Author.new(name: issue["title"], bio: issue["body"], gh_issue_number: issue["number"], gh_last_sync: Time.now)

    unless author.save
      Rails.logger.warn "There was an error creating an author for GitHub issue ##{issue["number"]}"
      return
    end

    book = Book.new(title: "#{author.name}'s Opus", author: author, publisher: author, price: 0.99)
    unless book.save
      Rails.logger.warn "There was an error creating a book for author #{author.id} from GitHub issue ##{issue["number"]}"
    end
  end

  # Updates an author from a github issue, or creates it with a warning if it doesn't exist
  def update_or_create_author_from_github(author, github_issue)
    if author
      update_author_from_github(author, github_issue)
    else
      Rails.logger.warn "Author for edited issue #{github_issue["number"]} doesn't exist. Creating it"
      create_author_for github_issue
    end
  end

  # Creates an author from a github issue, or updates it with a warning if it exists
  def create_or_update_author_from_github(author, github_issue)
    if author
      Rails.logger.warn "Opened issue has an existing author in the DB. How is this possible?. Updating it"
      update_author_from_github(author, github_issue)
    else
      create_author_for github_issue
    end
  end
end
