require 'spec_helper'
require 'ostruct'

require 'record_linkage/object_comparer'

module RecordLinkage
  describe ObjectComparer do
    let(:default_threshold) { 0.7 }
    let(:default_weight) { 1.0 }

    let(:comparer) do
      ObjectComparer.new do |config|
        config.default_threshold = default_threshold
        config.default_weight = default_weight

        matcher_arguments.each do |property1, property2, matcher_definition|
          config.add_matcher property1, property2, matcher_definition
        end
      end
    end

    describe '#classify_hash' do
      let(:attributes1) { {} }
      let(:attributes2) { {} }
      let(:object1) { OpenStruct.new(attributes1) }
      let(:object2) { OpenStruct.new(attributes2) }

      context 'a fuzzy string match' do
        let(:matcher_arguments) { [[:name, :display_name, :fuzzy_string]] }

        subject { comparer.classify_hash(object1, object2)[[:name, :display_name]] }

        context 'a perfect match' do
          let(:attributes1) { {name: 'Brian'} }
          let(:attributes2) { {display_name: 'Brian'} }

          it 'returns 1.0' do
            expect(subject).to eq(1.0)
          end

          context 'weight == 2.2' do
            let(:default_weight) { 2.2 }

            it 'returns 2.2' do
              expect(subject).to eq(2.2)
            end
          end
        end

        context 'a perfect mismatch' do
          let(:attributes1) { {name: '1'} }
          let(:attributes2) { {display_name: '2'} }

          it 'returns 0.0' do
            expect(subject).to eq(0.0)
          end
        end

        context 'a partial match' do
          let(:attributes1) { {name: 'Brian'} }
          let(:attributes2) { {display_name: 'Briau'} }

          it 'returns 0.92' do
            expect(subject).to eq(0.92)
          end

          context 'weight == 1.5' do
            let(:default_weight) { 1.5 }

            it 'returns 1.38' do
              expect(subject).to be_within(0.01).of(1.38)
            end
          end
        end
      end
    end
  end
end
