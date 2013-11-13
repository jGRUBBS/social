module Social
	module Posts
		class Instagram < ActiveRecord::Base
				
			attr_accessible :instagram_id, :photo, :caption
			
			validates :instagram_id, presence: true
			has_attached_file :photo
			
			include Social::Posts::UniversalAttributes
			include Social::Posts::Create

			def snippet; self.caption; end
			
			after_save do
				return false unless self.caption
			  self.caption.scan(/(?:\s|^)(?:#(?!\d+(?:\s|$)))(\w+)(?=\s|$)/i).flatten.each do |t|
			    self.parent.tag_relationships.create tag: Tag.find_or_create_by_name(t)
		    end
			end
			
			class << self
				
				def network; "Instagram"; end
				
				def import
					if Social::Engine.config.instagram_enabled
						client = Social::Engine::Instagram::Client.new client_id: Social::Engine.config.instagram_client_id, client_secret: Social::Engine.config.instagram_client_secret, access_token: Social::Engine.config.instagram_access_token
						uid = client.user_search(Social::Engine.config.instagram_username).first.id
						photos = client.user_recent_media(uid)
						photos.each do |photo|
							self.find_or_create_by_instagram_id(photo.id) do |p|
							  p.photo = URI.parse(photo.images.standard_resolution.url);
							  p.caption = photo.caption ? photo.caption.text : nil;
							  p.tags_found = photo.caption.to_s.scan(/(?:\s|^)(?:#(?!\d+(?:\s|$)))(\w+)(?=\s|$)/i).flatten
							  p.published_at = Time.at(Integer(photo.created_time))
							  p.address = photo.link
							end
						end
					else
						return false
					end
				end
				
			end
				
		end
	end
end
