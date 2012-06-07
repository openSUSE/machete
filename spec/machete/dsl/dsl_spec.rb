require "spec_helper"

module Machete::DSL
  describe Builder do
    before do
      @builder = Builder.new
    end

    it "responds to top level method" do
      @builder.should respond_to :send_with_arguments
    end

    context "build simple hash" do
      before do
        @result = Builder.build do
          send_with_arguments {}
        end
      end

      it "return proper hash" do
        @result.should == { :SendWithArguments => {} }
      end
    end

    context "build hash with arguments and blocks" do
      it "work with blocks" do
        result = Builder.build do
          attribute_1 do
            attribute_2(:value => 2)
          end
        end

        result.should ==  {
                            :attribute_1 => {
                              :attribute_2 => {
                                :value => 2
                              }
                            }
                          }
      end

      it "work with hash" do
        result = Builder.build do
          attribute_1(:value => 1)
        end

        result.should ==  {
                            :attribute_1 => {
                              :value => 1
                            }
                          }
      end

      it "work with arrays" do
        result = Builder.build do
          attributes(:array) do
            attribute_1(:value => 1)
            attribute_1(:value => 2)
          end
        end

        result.should ==  {
                            :attributes =>  [
                              { :attribute_1 => {
                                  :value => 1
                                }
                              },
                              { :attribute_1 => {
                                  :value => 2
                                }
                              }
                            ]
                          }
      end

      it "work with nested attributes" do
        result = Builder.build do
          attribute_1 do
            attribute_2 do
              nested_attribute(:value => "nested")
            end
          end
        end

        result.should ==  {
                            :attribute_1 => {
                              :attribute_2 => {
                                :nested_attribute => {
                                  :value => "nested"
                                }
                              }
                            }
                          }
      end
    end

    context "reserved words" do
      before do
        @result = Builder.build do
          _send do
            attribute_1(value: true)
          end
        end
      end

      it "respond to special methods" do
        @builder.should respond_to(:_send)
      end

      it "build proper hash with special method" do
        @result.should == {
                            :Send => {
                              :attribute_1 => {
                                :value => true
                              }
                            }
                          }
      end
    end
  end
end