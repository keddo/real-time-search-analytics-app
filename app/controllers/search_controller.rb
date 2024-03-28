class SearchController < ApplicationController

    def search_summary
        search_summary = SearchLog.summarize_search_queries
        render json: search_summary
    end
    # API endpoint to retrieve popular search terms
    def popular_search_terms
        search_terms = SearchLog.group(:text).order('count DESC').limit(10).count(:id)
        render json: search_terms
    end

    # API endpoint to retrieve search trends over time
    def search_trends
        search_trends = SearchLog.group_by_day(:created_at).count
        render json: search_trends
    end

    def analytics
        user_ip = request.remote_ip
        analyized_search = SearchLog.analyze_search(user_ip)
        
        render json: analyized_search
    end

    def search
        query = params[:query].strip # Remove leading and trailing whitespaces
        complete = text_complete?(query)
        # Check if the query is complete and sufficiently long
        if query.present? && query.match?(/\w{3,}/) && complete
             
            # Increment count attribute of the search
            search = SearchLog.find_or_initialize_by(user_ip: request.remote_ip, text: query)
            
            if search.persisted?
                # If the record already exists, increment the count
                search.increment!(:count)
            else
                # If the record is newly initialized, save it
                SearchLog.log(request.remote_ip, query)
            end
            # Log search query with IP address
            
            articles = Article.where("title ILIKE ?", "%#{query}%")
            render json: { results: articles }
        else
            # Return error response for short or incomplete queries
            render json: { error: 'Query too short or incomplete' }, status: :unprocessable_entity
        end
    end


    private

    def text_complete?(text)
        """
        Checks if the given text is complete or incomplete.
        """
        if text.nil? || text.strip.empty?
            # Empty or None text is considered incomplete
            return false
        end

        # Define regular expression pattern for subject, object, and verb
        pattern = /\b(?:he|she|it|they|I|you|we|who|what|how)\b\s+(?:\b\w+\b\s+){0,3}(?:\b\w+ing\b|\b\w+ed\b|\b\w+s\b|\b\w+\b)/i

        # Check if the text matches the pattern
        return !!(text =~ pattern)
    end

end
