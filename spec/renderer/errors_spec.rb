require 'spec_helper'

describe JSONAPI::Serializable::ErrorsRenderer, '#render' do
  let(:errors) do
    [
      JSONAPI::Serializable::Error.create(id: 'foo', title: 'bar'),
      JSONAPI::Serializable::Error.create(id: 'baz', title: 'foobar')
    ]
  end

  it 'renders an error document' do
    hash = subject.render(errors)

    expect(hash[:errors][0][:id]).to eq('foo')
    expect(hash[:errors][0][:title]).to eq('bar')
  end
end
