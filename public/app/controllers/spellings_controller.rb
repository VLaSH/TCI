class SpellingsController < ApplicationController
  def check
    headers["Content-Type"] = "text/plain"
    headers["charset"] = "utf-8"
    begin
      suggestions = check_spelling(params[:params][1], params[:method], params[:params][0])
      results = {"id" => nil, "result" => suggestions, "error" => nil}
    rescue
      results = {}
    end
    render :text => results.to_json
  end
end