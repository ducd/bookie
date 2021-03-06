require 'rails_helper'

RSpec.describe User::Friendship::Request::Create, type: :operation do
  let(:result) { User::Friendship::Request::Create.(params, dependencies) }

  let(:params) {
    {
      id: id,
      friendship_request: {
        comments: [{comment: message}],
      },
    }
  }

  let(:id) { user.id }

  let(:user) { Factory::User.create }

  let(:message) { Faker::Lorem.paragraph }

  let(:dependencies) { {current_user: current_user} }

  let(:current_user) { Factory::User.create }

  it 'successfully creates an open friendship request' do
    expect(result).to be_success
    expect(result['model']).to eq(user)

    result['contract.friendship_request'].model.tap do |request|
      expect(request).to be_persisted
      expect(request.state).to eq('open')
      expect(request.sender).to eq(current_user)
      expect(request.receiver).to eq(user)
      expect(request.comments.count).to eq(1)

      request.comments.first.tap do |comment|
        expect(comment).to be_persisted
        expect(comment.comment).to eq(message)
        expect(comment.author).to eq(current_user)
      end
    end
  end

  context 'with blank message' do
    let(:message) { '   ' }

    it 'fails with an error' do
      expect(result).to be_failure
      expect(result['contract.friendship_request'].comments.first.errors[:comment]).to \
        be_present
    end
  end

  context 'with invalid id' do
    let(:id) { 0 }

    it 'fails' do
      expect(result).to be_failure
    end
  end

  context 'as anonymous user' do
    let(:current_user) { nil }

    it 'fails' do
      expect(result).to be_failure
    end
  end

  context 'when the user behaves narcissistic' do
    let(:user) { current_user }

    it 'fails' do
      expect(result).to be_failure
    end
  end

  context 'when there already is a friendship request' do
    before {
      Factory::FriendshipRequest.create({
        id: user.id,
      }, {
        current_user: current_user,
      })
    }

    it 'fails' do
      expect(result).to be_failure
    end
  end

  context 'when there already is an inverse friendship request' do
    before {
      Factory::FriendshipRequest.create({
        id: current_user.id,
      }, {
        current_user: user,
      })
    }

    it 'fails' do
      expect(result).to be_failure
    end
  end

  context 'when the users are already friends' do
    before {
      Factory::FriendshipRequest.create({
        id: user.id,
      }, {
        current_user: current_user,
      })

      User::Friendship::Request::Accept.({
        id: user.received_friendship_requests.find_by(sender: current_user).id,
      }, {
        current_user: user,
      })
    }

    it 'fails' do
      expect(result).to be_failure
    end
  end
end
