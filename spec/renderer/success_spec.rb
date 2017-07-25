require 'spec_helper'

describe JSONAPI::Serializable::SuccessRenderer, '#render' do
  let(:posts) { [Post.new(id: 1), Post.new(id: 2)] }
  let(:user) do
    User.new(id: 'foo', name: 'Lucas', address: '22 Ruby drive', posts: posts)
  end

  it 'renders a success document' do
    hash = subject.render(user)

    expect(hash[:data][:type]).to eq(:users)
  end

  it 'renders a success document with included resources' do
    hash = subject.render(
      user, include: [:posts]
    )

    expect(hash[:data][:type]).to eq(:users)
    expect(hash[:included][0][:type]).to eq(:posts)
  end

  it 'finds a namespaced serializer' do
    hash = subject.render(
      user, include: [:posts], namespace: 'API'
    )

    expect(hash[:data][:type]).to eq(:api_users)
    expect(hash[:included][0][:type]).to eq(:api_posts)
  end

  context 'when providing a custom explicit inferrer' do
    it 'uses the inferred serializable classes' do
      inferrer = {
        User: 'API::SerializableUser',
        Post: 'API::SerializablePost'
      }
      hash = subject.render(user, include: [:posts], inferrer: inferrer)

      expect(hash[:data][:type]).to eq(:api_users)
      expect(hash[:included][0][:type]).to eq(:api_posts)
    end
  end

  context 'when providing a custom implicit inferrer' do
    it 'uses the inferred serializable classes' do
      inferrer = Hash.new { |h, k| h[k] = "API::Serializable#{k}" }
      hash = subject.render(user, include: [:posts], inferrer: inferrer)

      expect(hash[:data][:type]).to eq(:api_users)
      expect(hash[:included][0][:type]).to eq(:api_posts)
    end
  end

  context 'when providing a custom inferrer and a namespace' do
    it 'uses the inferred serializable classes' do
      inferrer = Hash.new { |h, k| h[k] = "Serializable#{k}" }
      hash = subject.render(user, include: [:posts],
                            inferrer: inferrer, namespace: 'API')

      expect(hash[:data][:type]).to eq(:api_users)
      expect(hash[:included][0][:type]).to eq(:api_posts)
    end
  end
end
