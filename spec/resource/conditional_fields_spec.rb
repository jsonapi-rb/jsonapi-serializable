require 'spec_helper'

describe JSONAPI::Serializable::Resource do
  let(:klass) do
    Class.new(JSONAPI::Serializable::Resource) do
      type 'foo'
      id { 'bar' }
    end
  end

  let(:object) { User.new }
  let(:resource) do
    klass.new(object: object, conditional: conditional)
  end

  context 'when the attribute is conditional' do
    before do
      klass.class_eval do
        prepend JSONAPI::Serializable::Resource::ConditionalFields
      end
    end

    subject { resource.as_jsonapi[:attributes] }

    context 'via :if' do
      before do
        klass.class_eval do
          attribute :name, if: proc { @conditional } do
            'foo'
          end
        end
      end

      context 'and the clause is true' do
        let(:conditional) { true }

        it { is_expected.to eq(name: 'foo') }
      end

      context 'and the clause is false' do
        let(:conditional) { false }

        it { is_expected.to be_nil }
      end
    end

    context 'via :unless' do
      before do
        klass.class_eval do
          attribute :name, unless: proc { @conditional } do
            'foo'
          end
        end
      end

      context 'and the clause is true' do
        let(:conditional) { true }

        it { is_expected.to be_nil }
      end

      context 'and the clause is false' do
        let(:conditional) { false }

        it { is_expected.to eq(name: 'foo') }
      end
    end
  end

  context 'when relationship is conditional' do
    before do
      klass.class_eval do
        prepend JSONAPI::Serializable::Resource::ConditionalFields

        relationship :posts, if: -> { false }
      end
    end

    subject { resource.as_jsonapi[:relationships] }

    context 'and the clause is false' do
      let(:conditional) { false }

      it { is_expected.to be_nil }
    end
  end

  context 'when a link is conditional' do
    before do
      klass.class_eval do
        prepend JSONAPI::Serializable::Resource::ConditionalFields

        link :self, if: proc { @conditional } do
          'https://example.com/users/42'
        end
      end
    end

    subject { resource.as_jsonapi[:links] }

    context 'and the clause is true' do
      let(:conditional) { true }

      it { is_expected.to eq(self: 'https://example.com/users/42') }
    end

    context 'and the clause is false' do
      let(:conditional) { false }

      it { is_expected.to be_nil }
    end
  end

  context 'when inheriting' do
    before do
      klass.class_eval do
        prepend JSONAPI::Serializable::Resource::ConditionalFields

        relationship :posts, if: -> { false }
      end
    end

    let(:subclass) { Class.new(klass) }
    let(:resource) { subclass.new(object: object) }

    subject { resource.as_jsonapi[:relationships] }

    context 'and the clause is false' do
      let(:conditional) { false }

      it { is_expected.to be_nil }
    end
  end

  context 'when a field and a link have the same name' do
    before do
      klass.class_eval do
        prepend JSONAPI::Serializable::Resource::ConditionalFields

        attribute :name, if: proc { @conditional } do
          'attribute'
        end

        link :name, unless: proc { @conditional } do
          'link'
        end
      end
    end

    let(:conditional) { true }
    subject { resource.as_jsonapi }

    it "doesn't override previously registered condition" do
      expect(subject[:attributes]).to eq(name: 'attribute')
      expect(subject).not_to have_key(:links)
    end
  end
end
