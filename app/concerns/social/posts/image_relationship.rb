module Social
	module Posts
		module ImageRelationship
			
			extend ActiveSupport::Concern
			
			included do
				default_scope {includes(:images)}
				has_many :images, as: :parent, class_name: "Social::Image", dependent: :destroy
			end
			
		end
	end
end