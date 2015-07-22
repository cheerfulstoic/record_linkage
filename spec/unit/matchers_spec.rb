require 'spec_helper'
require 'ostruct'

require 'record_linkage/matcher'

module RecordLinkage
  describe Matchers do
    let(:options) { {} }
    subject { Matchers.call_matcher(matcher_name, value1, value2, options) }

    let_context matcher_name: :fuzzy_string do
      let_context value1: 'Brian' do
        let_context 'a perfect match', value2: 'Brian' do
          it { should == 1.0 }
        end

        let_context 'a perfect mismatch', value2: 'Csjbo' do
          it { should == 0.0 }
        end

        let_context 'a partial match', value2: 'Briau' do
          it { should == 0.92 }
        end
      end
    end

    let_context matcher_name: :exact_string do
      let_context value1: 'Brian' do
        let_context 'a perfect match', value2: 'Brian' do
          it { should == 1.0 }
        end

        let_context 'a perfect mismatch', value2: 'Csjbo' do
          it { should == 0.0 }
        end

        let_context 'a partial match', value2: 'Briau' do
          it { should == 0.0 }
        end
      end
    end

    let_context matcher_name: :number_nearness do
      let_context value1: 10 do
        let_context value2: 10 do
          it { expect { subject }.to raise_error(ArgumentError) }

          let_context options: {max: 10} do
            it { should == 1.0 }
          end
        end

        let_context options: {max: 10} do
          let_context(value2: -1) { it { should == 0.0 } }
          let_context(value2: 0) { it { should == 0.0 } }
          let_context(value2: 1) { it { should == 0.1 } }
          let_context(value2: 6) { it { should == 0.6 } }
          let_context(value2: 9) { it { should == 0.9 } }
          let_context(value2: 11) { it { should == 0.9 } }
          let_context(value2: 13) { it { should == 0.7 } }
          let_context(value2: 19) { it { should == 0.1 } }
          let_context(value2: 20) { it { should == 0.0 } }
          let_context(value2: 21) { it { should == 0.0 } }
        end

        let_context options: {max: 2} do
          let_context(value2: 7.9) { it { should == 0.00 } }
          let_context(value2: 8.0) { it { should == 0.00 } }
          let_context(value2: 8.1) { it { should be_within(0.0001).of(0.05) } }
          let_context(value2: 9.1) { it { should be_within(0.0001).of(0.55) } }
          let_context(value2: 9.5) { it { should be_within(0.0001).of(0.75) } }
          let_context(value2: 10.0) { it { should == 1.0 } }
        end
      end
    end

    let_context matcher_name: :array_fuzzy_string do
      let_context value1: %w(Brian) do
        let_context 'a perfect match', value2: %w(Brian) do
          it { should == 1.0 }
        end

        let_context 'a perfect mismatch', value2: %w(Csjbo) do
          it { should == 0.0 }
        end

        let_context 'a partial match', value2: %w(Briau) do
          it { should == 0.92 }
        end

        let_context value2: %w(Brian Briau) do
          it { should == 1.92 }
        end

        let_context value2: %w(Brian Csjbo) do
          it { should == 1.0 }
        end
      end
    end

    let_context matcher_name: :array_exact_string do
      let_context value1: %w(Brian) do
        let_context 'a perfect match', value2: %w(Brian) do
          it { should == 1.0 }
        end

        let_context 'a perfect mismatch', value2: %w(Csjbo) do
          it { should == 0.0 }
        end

        let_context 'a partial match', value2: %w(Briau) do
          it { should == 0.0 }
        end

        let_context value2: %w(Brian Briau) do
          it { should == 1.0 }
        end

        let_context value2: %w(Brian Csjbo) do
          it { should == 1.0 }
        end
      end
    end
  end
end
