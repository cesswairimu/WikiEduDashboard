class Article < ActiveRecord::Base
  has_many :revisions

    # Instance methods
  def update_views

  end

  def character_sum
    read_attribute(:character_sum) || self.revisions.sum(:characters)
  end

  def update(data={})
    if data.blank?
      # Implement method for single-article lookup
    end

    self.title = data["page_title"]
    self.save
  end

  def update_cache
    self.character_sum = self.revisions.sum(:characters)
    self.save
  end

  # Class methods
  def self.update_all_articles
    articles = Utils.chunk_requests(User.all) { |block|
      Replica.get_articles_edited_this_term_by_users block
    }
    articles.each do |a|
      article = Article.find_or_create_by(id: a["page_id"])
      article.update a
    end
  end

  def self.update_all_caches
    Article.all.each do |a|
      a.update_cache
    end
  end
end