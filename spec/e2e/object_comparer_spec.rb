require 'spec_helper'
require 'ostruct'

require 'record_linkage/object_comparer'

module RecordLinkage # rubocop:disable Style/Documentation
  describe ObjectComparer do
    let(:default_weight) { 1.0 }
    let(:matcher_weight) { nil }

    let(:comparer) do
      ObjectComparer.new do |config|
        config.default_weight = default_weight

        matcher_arguments.each do |property1, property2, matcher_definition|
          config.add_matcher property1,
                             property2,
                             matcher_definition,
                             weight: matcher_weight
        end
      end
    end

    describe '#classify_hash' do
      let(:object1) { OpenStruct.new(name: name) }
      let(:object2) { OpenStruct.new(forename: forename) }
      let(:matcher_arguments) { [[:name, :forename, matcher_definition]] }

      subject { comparer.classify_hash(object1, object2)[[:name, :forename]] }

      let_context matcher_definition: :fuzzy_string do
        let_context name: 'Brian' do
          let_context 'a perfect match', forename: 'Brian' do
            it { should == 1.0 }

            let_context matcher_weight: 2.3 do
              it { should == 2.3 }
            end

            let_context default_weight: 2.2 do
              it { should == 2.2 }

              let_context matcher_weight: 2.3 do
                it { should == 2.3 }
              end
            end
          end

          let_context 'a perfect mismatch', forename: 'Csjbo' do
            it { should == 0.0 }
          end

          let_context 'a partial match', forename: 'Briau' do
            it { should == 0.92 }

            let_context default_weight: 1.5 do
              it { should be_within(0.01).of(1.38) }
            end
          end
        end
      end

      context 'user-specified matcher block' do
        let(:matcher_definition) do
          proc do |value1, value2, options|
            expect(options[:object1]).to be(object1)
            expect(options[:object2]).to be(object2)
            case value1
            when 'Brian'
              1.0
            when value2
              0.5
            else
              Matchers.call_matcher(:fuzzy_string, value1, value2, options)
            end
          end
        end

        let_context name: 'Brian' do
          let_context(forename: 'Brian') { it { should == 1.0 } }
          let_context(forename: 'Briau') { it { should == 1.0 } }
          let_context(forename: 'Csjbo') { it { should == 1.0 } }
        end

        let_context name: 'Sarah' do
          let_context(forename: 'Sarah') { it { should == 0.5 } }
          let_context(forename: 'Sarau') { it { should == 0.92 } }
          let_context(forename: 'Brian') { it { should == 0.6 } }
        end
      end
    end
  end
end
