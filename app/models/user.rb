class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
# Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

         has_many :books
         has_many :favorites, dependent: :destroy
         has_many :favorite_books, through: :favorites, source: :book
         has_many :comments

         attachment :profile_image

         validates :name, presence: true, uniqueness: true, length: 2..20
         validates :introduction, length: { maximum: 50 }

         has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
         has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
         has_many :followers, through: :reverse_of_relationships, source: :follower
         has_many :followings, through: :relationships, source: :followed

         has_many :user_rooms
         has_many :chats
         
         # is_deletedがfalseならtrueを返すようにしている
         def active_for_authentication?
           super && (is_deleted == false)
         end

        def follow(user_id)
         relationships.create(followed_id: user_id)
        end

        def unfollow(user_id)
         relationships.find_by(followed_id: user_id).destroy
        end

        def following?(user)
         followings.include?(user)
        end

        def self.search(search,word)
         if search == "forward_match"
          @user = User.where("name LIKE?","#{word}%")
         elsif search == "backward_match"
          @user = User.where("name LIKE?","%#{word}")
         elsif search == "perfect_match"
          @user = User.where("#{word}")
         elsif search == "partial_match"
          @user = User.where("name LIKE?","%#{word}%")
         else
          @user = User.all
         end
        end
end