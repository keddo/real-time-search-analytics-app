class SearchLog < ApplicationRecord
    def self.log(ip, query)
        # Log search query with IP address
        SearchLog.create(user_ip: ip, text: query)
    end

    # Method to aggregate and summarize search queries
    def self.summarize_search_queries
        # Group similar search queries together and count their occurrences
        search_summary = group(:text).count

        # Filter out incomplete or redundant search queries (example criteria: queries with fewer than 3 characters)
        search_summary.reject! { |query, count| query.length < 3 }

        # Sort the search summary by count in descending order
        search_summary = search_summary.sort_by { |_query, count| -count }

        # Return the summarized search data
        search_summary
    end

    # Method to analyze search 
    def self.analyze_search(user_ip)
        # Ensure user_ip is present
        raise ArgumentError, "Please provide a user IP to search for" unless user_ip.present?

        # Get all search logs for the user IP
        all_searches = SearchLog.where(user_ip: user_ip).order("count DESC")

        # Return the search logs as an array
        all_searches.to_a
    end
end
