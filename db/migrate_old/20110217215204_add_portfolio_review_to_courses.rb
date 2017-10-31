class AddPortfolioReviewToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :portfolio_review, :boolean, :default => false
  end

  def self.down
    remove_column :courses, :portfolio_review
  end
end
