require 'spec_helper'

describe JSONAPI::Serializable::Renderer, '#render_errors' do
  let(:errors) do
    [
      { id: 'foo', title: 'bar' },
      { id: 'baz', title: 'foobar' }
    ]
  end

  it 'renders an error document' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      id { @object[:id] }
      title { @object[:title] }
    end
    hash = subject.render_errors(errors, class: { Hash: klass })

    expect(hash[:errors][0][:id]).to eq('foo')
    expect(hash[:errors][0][:title]).to eq('bar')
  end
end
