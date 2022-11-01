# frozen_string_literal: true

class InlineRenderer
  def initialize(object, current_account, template)
    @object          = object
    @current_account = current_account
    @template        = template
  end

  def render
    case @template
    when :status
      serializer = REST::StatusSerializer
      preload_associations_for_status
    when :notification
      serializer = REST::NotificationSerializer
      preload_associations_for_notification
    when :conversation
      serializer = REST::ConversationSerializer
      preload_associations_for_conversation
    when :announcement
      serializer = REST::AnnouncementSerializer
      preload_associations_for_announcement
    when :reaction
      serializer = REST::ReactionSerializer
      preload_associations_for_reaction
    when :encrypted_message
      serializer = REST::EncryptedMessageSerializer
      preload_associations_for_encrypted_message
    else
      return
    end

    serializable_resource = ActiveModelSerializers::SerializableResource.new(@object, serializer: serializer, scope: current_user, scope_name: :current_user)
    serializable_resource.as_json
  end

  def self.render(object, current_account, template)
    new(object, current_account, template).render
  end

  private

  def preload_associations_for_status
    ActiveRecord::Associations::Preloader.new.preload(@object, [
      :status_stat,
      :media_attachments,
      :application,
      :tags,
      :preloadable_poll,
      :preview_cards,
      {
        active_mentions: :account,
        account: [
          :account_stat,
          {
            moved_to_account: :account_stat,
          },
        ],
        reblog: [
          :status_stat,
          :media_attachments,
          :application,
          :tags,
          :preloadable_poll,
          :preview_cards,
          {
            active_mentions: :account,
            account: [
              :account_stat,
              {
                moved_to_account: :account_stat,
              },
            ],
          },
        ],
      },
    ])
  end

  def preload_associations_for_notification; end

  def preload_associations_for_conversation; end

  def preload_associations_for_announcement; end

  def preload_associations_for_reaction; end

  def preload_associations_for_encrypted_message; end

  def current_user
    @current_account&.user
  end
end
