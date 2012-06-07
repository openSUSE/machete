require "spec_helper"

describe "to_m" do
  context String do
    describe "to_m" do
      it "returns empty string for an empty string" do
        "".to_m.should == ""
      end

      it "returns itself for a non-empty string" do
        "string".to_m.should == "string"
      end
    end
  end

  context Hash do
    describe "to_m" do
      it "returns empty string in case of empty hash" do
        {}.to_m.should == ""
      end

      it "close content with '<>' when key start with capital letter" do
        { :SendWithArguments => nil }.to_m.should == "SendWithArguments<>"
      end

      it "add attribute to AST node" do
        { :SendWithArguments => { :attribute => 1 } }.to_m.should == "SendWithArguments<attribute = 1>"
      end

      it "add many attributes to AST node separated by comma" do
        {
          :SendWithArguments =>
            {
              :attribute_1 => 1,
              :attribute_2 => 2
            }
        }.to_m.should == "SendWithArguments<attribute_1 = 1, attribute_2 = 2>"
      end
    end
  end

  context Array do
    describe "to_m" do
      it "returns empty array for an empty array" do
        [].to_m.should == "[]"
      end

      it "return array of arguments" do
        array = [
                  { :attribute_1 => 1 },
                  { :attribute_1 => 2 }
                ]

        array.to_m.should == "[attribute_1 = 1, attribute_1 = 2]"
      end
    end
  end

  context Fixnum do
    describe "to_m" do
      it "return string version of Fixnum" do
        1.to_m.should == "1"
      end
    end
  end

  context NilClass do
    describe "to_m" do
      it "return empty string" do
        nil.to_m.should == ""
      end
    end
  end
end