require 'spec_helper'

describe JSONAPI::Serializable::Error, '.id' do
  it 'accepts a string' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      id 'foo'
    end
    error = klass.new
    actual = error.as_jsonapi[:id]
    expected = 'foo'

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.id' do
  it 'accepts a block' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      id { 'foo' }
    end
    error = klass.new
    actual = error.as_jsonapi[:id]
    expected = 'foo'

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.status' do
  it 'accepts a string' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      status 'foo'
    end
    error = klass.new
    actual = error.as_jsonapi[:status]
    expected = 'foo'

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.status' do
  it 'accepts a block' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      status { 'foo' }
    end
    error = klass.new
    actual = error.as_jsonapi[:status]
    expected = 'foo'

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.code' do
  it 'accepts a string' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      code 'foo'
    end
    error = klass.new
    actual = error.as_jsonapi[:code]
    expected = 'foo'

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.code' do
  it 'accepts a block' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      code { 'foo' }
    end
    error = klass.new
    actual = error.as_jsonapi[:code]
    expected = 'foo'

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.title' do
  it 'accepts a string' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      title 'foo'
    end
    error = klass.new
    actual = error.as_jsonapi[:title]
    expected = 'foo'

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.title' do
  it 'accepts a block' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      title { 'foo' }
    end
    error = klass.new
    actual = error.as_jsonapi[:title]
    expected = 'foo'

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.detail' do
  it 'accepts a string' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      detail 'foo'
    end
    error = klass.new
    actual = error.as_jsonapi[:detail]
    expected = 'foo'

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.detail' do
  it 'accepts a block' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      detail { 'foo' }
    end
    error = klass.new
    actual = error.as_jsonapi[:detail]
    expected = 'foo'

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.meta' do
  it 'accepts a string' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      meta 'foo'
    end
    error = klass.new
    actual = error.as_jsonapi[:meta]
    expected = 'foo'

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.meta' do
  it 'accepts a block' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      meta { 'foo' }
    end
    error = klass.new
    actual = error.as_jsonapi[:meta]
    expected = 'foo'

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.links' do
  it 'accepts a block' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      link(:about) do
        href 'foo://bar'
        meta foo: 'bar'
      end
    end
    error = klass.new
    actual = error.as_jsonapi[:links][:about]
    expected = { href: 'foo://bar', meta: { foo: 'bar' } }

    expect(actual).to eq(expected)
  end
end

describe JSONAPI::Serializable::Error, '.source' do
  it 'accepts a block' do
    klass = Class.new(JSONAPI::Serializable::Error) do
      source do
        pointer 'foo'
        parameter 'bar'
      end
    end
    error = klass.new
    actual = error.as_jsonapi[:source]
    expected = { pointer: 'foo', parameter: 'bar' }

    expect(actual).to eq(expected)
  end
end
