module Social
	module Posts
		module Facebook
			class Post < ActiveRecord::Base
				
				attr_accessible :facebook_id
				
				default_scope { includes(:post) }
				belongs_to :post, polymorphic: true
				validates :facebook_id, presence: true
				attr_accessor :object
				
				include Social::Posts::Create
				
				before_validation do
					if Social::Engine.config.facebook_enabled
						case object.type
							when "status"
								return false if object.message.nil?
								self.post = Facebook::Posts::Status.create message: object.message
							when "photo"
								self.post = Facebook::Posts::Photo.create photo: URI.parse(object.picture), caption: object.message
							when "link"
								self.post = Facebook::Posts::Link.create link: object.link, icon: URI.parse(object.icon), message: object.message
							else
								return false
						end
						self.published_at = object.created_time
					else
						return false
					end
				end
				
			end
		end
	end
end
