require 'spec_helper'

describe JSONAPI::Serializable::Renderer, '#render_relationship' do
  let(:posts) { [Post.new(id: 1), Post.new(id: 2)] }
  let(:user) do
    User.new(id: 'foo', name: 'Lucas', address: '22 Ruby drive', posts: posts)
  end

  it 'renders a relationship document' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'

      has_many(:posts) do
        link(:self) { "http://api.example.com/users/#{@object.id}/relationships/posts" }
        link(:related) { "http://api.example.com/users/#{@object.id}/posts" }
        meta posts_count: @object.posts.size
      end
    end
    hash = subject.render(user,
                          relationship: :posts,
                          class: { User: klass, Post: SerializablePost })
    expected = {
      data: [{ type: :posts, id: '1' }, { type: :posts, id: '2' }],
      links: {
        self: "http://api.example.com/users/foo/relationships/posts",
        related: "http://api.example.com/users/foo/posts"
      },
      meta: {
        posts_count: 2
      }
    }

    expect(hash).to eq(expected)
  end

  it 'can interigate included? in the meta block' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'

      has_many(:posts) do
        meta do
          included?
        end
      end
    end
    expect_any_instance_of(JSONAPI::Serializable::Relationship).to receive(:included?)
    subject.render(user, class: { User: klass, Post: SerializablePost })
  end
end
