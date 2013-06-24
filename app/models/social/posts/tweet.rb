module Social
	module Posts
		class Tweet < ActiveRecord::Base

			validates :twitter_id, presence: true
			validates :tweet, presence: true
			
			include Social::Posts::Create

			def self.import
				tweets = Twitter.user_timeline Social::Engine.config.twitter_username
				tweets.each do |tweet|
					self.find_or_create_by(twitter_id: tweet.id) { |p| p.tweet = tweet.text; p.published_at = tweet.created_at }
				end
			end

		end
	end
end
