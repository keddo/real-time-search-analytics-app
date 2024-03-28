class SearchLogController < ApplicationController
    def search_summary
        search_summary = SearchesLog.summarize_search_queries
        render json: search_summary
    end
    # API endpoint to retrieve popular search terms
    def popular_search_terms
        search_terms = SearchesLog.group(:query).order('count DESC').limit(10).count(:id)
        render json: search_terms
    end

    # API endpoint to retrieve search trends over time
    def search_trends
        search_trends = SearchesLog.group_by_day(:created_at).count
        render json: search_trends
    end

    def analytics
        user_ip = request.remote_ip
        search_patterns = SearchesLog.analyze_search_patterns
        
        render json: search_patterns
    end

    def search
        query = params[:query].strip # Remove leading and trailing whitespaces

        # Check if the query is complete and sufficiently long
        if query.present? && query.match?(/\w{3,}/)
        # Increment count attribute of the search
        search = SearchesLog.find_or_initialize_by(user_ip: request.remote_ip, text: query)
        
        if search.persisted?
            # If the record already exists, increment the count
            search.increment!(:count)
        else
            # If the record is newly initialized, save it
            # SearchesLog.log(request.remote_ip, query)
            search.save
        end
        # Log search query with IP address
        
        articles = Article.where("title ILIKE ?", "%#{query}%")
        render json: { results: articles }
        else
        # Return error response for short or incomplete queries
        render json: { error: 'Query too short or incomplete' }, status: :unprocessable_entity
        end
    end
end
