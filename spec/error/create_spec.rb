require 'spec_helper'

describe JSONAPI::Serializable::Error, '.create' do
  it 'ignores unknown members' do
    hash = { unknown: 'foo' }

    error = JSONAPI::Serializable::Error.create(hash)
    expect(error.as_jsonapi).to eq({})
  end

  it 'supports id' do
    hash = { id: 'foo' }

    error = JSONAPI::Serializable::Error.create(hash)
    expect(error.as_jsonapi).to eq(hash)
  end

  it 'supports status' do
    hash = { status: 'foo' }

    error = JSONAPI::Serializable::Error.create(hash)
    expect(error.as_jsonapi).to eq(hash)
  end

  it 'supports code' do
    hash = { code: 'foo' }

    error = JSONAPI::Serializable::Error.create(hash)
    expect(error.as_jsonapi).to eq(hash)
  end

  it 'supports title' do
    hash = { title: 'foo' }

    error = JSONAPI::Serializable::Error.create(hash)
    expect(error.as_jsonapi).to eq(hash)
  end

  it 'supports detail' do
    hash = { detail: 'foo' }

    error = JSONAPI::Serializable::Error.create(hash)
    expect(error.as_jsonapi).to eq(hash)
  end

  it 'supports meta' do
    hash = { meta: { foo: 'bar' } }

    error = JSONAPI::Serializable::Error.create(hash)
    expect(error.as_jsonapi).to eq(hash)
  end

  it 'supports links' do
    hash = {
      links: {
        about: {
          href: 'foo://bar',
          meta: { foo: 'bar' }
        }
      }
    }

    error = JSONAPI::Serializable::Error.create(hash)
    expect(error.as_jsonapi).to eq(hash)
  end

  it 'supports source' do
    hash = {
      source: {
        pointer: 'foo',
        parameter: 'bar'
      }
    }

    error = JSONAPI::Serializable::Error.create(hash)
    expect(error.as_jsonapi).to eq(hash)
  end

  it 'supports combinations of members' do
    hash = {
      status: '422',
      title: 'Invalid foo bar',
      source: {
        pointer: 'foo',
        parameter: 'bar'
      }
    }

    error = JSONAPI::Serializable::Error.create(hash)
    expect(error.as_jsonapi).to eq(hash)
  end
end
