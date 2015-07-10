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
      let(:object1) { OpenStruct.new(name: name) }
      let(:object2) { OpenStruct.new(forename: forename) }
      let(:matcher_arguments) { [[:name, :forename, matcher_definition]] }

      subject { comparer.classify_hash(object1, object2)[[:name, :forename]] }

      let_context matcher_definition: :fuzzy_string do
        let_context 'a perfect match', name: 'Brian', forename: 'Brian' do
          it { should == 1.0 }

          let_context default_weight: 2.2 do
            it { should == 2.2 }
          end
        end

        let_context 'a perfect mismatch', name: '1', forename: '2' do
          it { should == 0.0 }
        end

        let_context 'a partial match', name: 'Brian', forename: 'Briau' do
          it { should == 0.92 }

          let_context default_weight: 1.5 do
            it { should be_within(0.01).of(1.38) }
          end
        end
      end

      let_context matcher_definition: :exact_string do
        let_context 'a perfect match', name: 'Brian', forename: 'Brian' do
          it { should == 1.0 }

          let_context default_weight: 2.2 do
            it { should == 2.2 }
          end
        end

        let_context 'a perfect mismatch', name: '1', forename: '2' do
          it { should == 0.0 }
        end

        let_context 'a partial match', name: 'Brian', forename: 'Briau' do
          it { should == 0.0 }

          let_context default_weight: 1.5 do
            it { should == 0.0 }
          end
        end
      end

      let_context matcher_definition: :array_fuzzy_string do
        let_context name: %w(Brian) do
          let_context 'a perfect match', forename: %w(Brian) do
            it { should == 1.0 }

            let_context default_weight: 2.2 do
              it { should == 2.2 }
            end
          end

          let_context 'a perfect mismatch', forename: %w(Csjbo) do
            it { should == 0.0 }
          end

          let_context 'a partial match', forename: %w(Briau) do
            it { should == 0.92 }

            let_context default_weight: 1.5 do
              it { should be_within(0.01).of(1.38) }
            end
          end

          let_context forename: %w(Brian Briau) do
            it { should == 1.92 }

            let_context default_weight: 1.5 do
              it { should == 2.88 }
            end
          end

          let_context forename: %w(Brian Csjbo) do
            it { should == 1.0 }

            let_context default_weight: 1.5 do
              it { should == 1.5 }
            end
          end
        end
      end
    end
  end
end
