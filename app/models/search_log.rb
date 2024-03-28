class SearchLog < ApplicationRecord
    def self.log(ip, query)
        # Log search query with IP address
        SearchesLog.create(user_ip: ip, text: query)
    end

    # Method to aggregate and summarize search queries
    def self.summarize_search_queries
        # Group similar search queries together and count their occurrences
        search_summary = group(:query).count

        # Filter out incomplete or redundant search queries (example criteria: queries with fewer than 3 characters)
        search_summary.reject! { |query, count| query.length < 3 }

        # Sort the search summary by count in descending order
        search_summary = search_summary.sort_by { |_query, count| -count }

        # Return the summarized search data
        search_summary
    end

    # Method to analyze search patterns and identify trends grouped by user IP
    def self.analyze_search_patterns_by_ip
        # Get all complete search queries and user IPs from the database
        all_searches = where("LENGTH(query) >= 3").pluck(:query, :user_ip)

        # Analyze search patterns grouped by user IP
        search_patterns_by_ip = Hash.new { |hash, key| hash[key] = { overall_count: 0, searches_by_ip: Hash.new(0) } }
        all_searches.each do |query, ip_address|
        # Normalize the query (convert to lowercase, remove whitespace, etc.)
        normalized_query = query.downcase.strip

        # Increment the overall count for this query
        search_patterns_by_ip[normalized_query][:overall_count] += 1

        # Increment the count for this query for the user IP
        search_patterns_by_ip[normalized_query][:searches_by_ip][ip_address] += 1
        end

        # Return the search patterns grouped by user IP
        search_patterns_by_ip
    end
end
