require 'spec_helper'

describe JSONAPI::Serializable, '.resources_for' do
  let(:inferrer) { Hash[Post: API::SerializablePost] }

  it 'returns nil if the object is nil' do
    expect(described_class.resources_for(nil, {}, inferrer)).to be(nil)
  end

  it 'returns an array if the object is an array of resources' do
    resources = described_class.resources_for([Post.new], {}, inferrer)

    expect(resources).to be_a(Array)
    expect(resources[0]).to be_a(JSONAPI::Serializable::Resource)
  end

  it 'returns a resource' do
    resources = described_class.resources_for(Post.new, {}, inferrer)

    expect(resources).to be_a(JSONAPI::Serializable::Resource)
  end

  it 'raises an exception if unable to infer serializable class' do
    expect {
      described_class.resources_for(User.new, {}, inferrer)
    }.to raise_error(JSONAPI::Serializable::UndefinedSerializableClass)
  end
end
