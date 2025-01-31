# frozen_string_literal: true

require "dry/schema/message_compiler"

RSpec.describe Dry::Schema::MessageCompiler do
  subject(:message_compiler) { Dry::Schema::MessageCompiler.new(messages) }

  include_context "predicate helper"

  let(:messages) do
    Dry::Schema::Messages::YAML.build.merge(
      en: {
        dry_schema: {
          errors: {
            key?: {
              arg: {
                default: "+%{name}+ key is missing in the hash"
              },
              value: {
                gender: "Please provide your gender"
              }
            },
            rules: {
              address: {
                filled?: "Please provide your address"
              }
            }
          }
        }
      },
      pl: {
        dry_schema: {
          rules: {
            email: "adres email"
          },
          errors: {
            email?: "nie jest poprawny"
          }
        }
      }
    )
  end

  describe "#call with flat inputs" do
    let(:ast) do
      [
        [:failure, [:name, p(:key?, :name)]],
        [:failure, [:gender, p(:key?, :gender)]],
        [:key, [:age, [:failure, [:age, p(:gt?, 18)]]]],
        [:key, [:email, [:failure, [:email, p(:filled?, "")]]]],
        [:key, [:address, [:failure, [:address, p(:filled?, "")]]]]
      ]
    end

    it "converts error ast into another format" do
      expect(message_compiler.(ast).to_h).to eql(
        name: ["+name+ key is missing in the hash"],
        gender: ["Please provide your gender"],
        age: ["must be greater than 18"],
        email: ["must be filled"],
        address: ["Please provide your address"]
      )
    end
  end

  describe "#visit with an :input node" do
    context "full message" do
      it "returns full message including rule name" do
        msg = message_compiler.with(full: true).visit(
          [:failure, [:num, [:key, [:num, p(:int?, "2")]]]]
        )

        expect(msg).to eql("num must be an integer")
      end
    end

    context "rule name translations" do
      it "translates rule name and its message" do
        msg = message_compiler.with(locale: :pl, full: true).visit(
          [:failure, [:email, [:key, [:email, p(:email?, "oops")]]]]
        )

        expect(msg).to eql("adres email nie jest poprawny")
      end
    end

    describe ":empty?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:tags, [:key, [:tags, p(:empty?, nil)]]]]
        )

        expect(msg).to eql("must be empty")
      end
    end

    describe ":excluded_from?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:excluded_from?, [1, 2, 3], 2)]]]]
        )

        expect(msg).to eql("must not be one of: 1, 2, 3")
      end
    end

    describe ":excludes?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:array, [:key, [:array, p(:excludes?, 2, [1, 2])]]]]
        )

        expect(msg).to eql("must not include 2")
      end
    end

    describe ":included_in?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:included_in?, [1, 2, 3], :num)]]]]
        )

        expect(msg).to eql("must be one of: 1, 2, 3")
      end
    end

    describe ":includes?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:includes?, 2, [1])]]]]
        )

        expect(msg).to eql("must include 2")
      end
    end

    describe ":gt?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:gt?, 3, 2)]]]]
        )

        expect(msg).to eql("must be greater than 3")
      end
    end

    describe ":gteq?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:gteq?, 3, 2)]]]]
        )

        expect(msg).to eql("must be greater than or equal to 3")
      end
    end

    describe ":lt?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:lt?, 3, 2)]]]]
        )

        expect(msg).to eql("must be less than 3")
      end
    end

    describe ":lteq?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:lteq?, 3, 2)]]]]
        )

        expect(msg).to eql("must be less than or equal to 3")
      end
    end

    describe ":hash?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:address, [:key, [:address, p(:hash?, "")]]]]
        )

        expect(msg).to eql("must be a hash")
      end
    end

    describe ":array?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:phone_numbers, [:key, [:phone, p(:array?, "")]]]]
        )

        expect(msg).to eql("must be an array")
      end
    end

    describe ":int?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:int?, "2")]]]]
        )

        expect(msg).to eql("must be an integer")
      end
    end

    describe ":float?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:float?, "2")]]]]
        )

        expect(msg).to eql("must be a float")
      end
    end

    describe ":decimal?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:decimal?, "2")]]]]
        )

        expect(msg).to eql("must be a decimal")
      end
    end

    describe ":date?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:date?, "2")]]]]
        )

        expect(msg).to eql("must be a date")
      end
    end

    describe ":date_time?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:date_time?, "2")]]]]
        )

        expect(msg).to eql("must be a date time")
      end
    end

    describe ":time?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:time?, "2")]]]]
        )

        expect(msg).to eql("must be a time")
      end
    end

    describe ":max_size?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:max_size?, 3, "abcd")]]]]
        )

        expect(msg).to eql("size cannot be greater than 3")
      end
    end

    describe ":min_size?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:min_size?, 3, "ab")]]]]
        )

        expect(msg).to eql("size cannot be less than 3")
      end
    end

    describe ":nil?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:nil?, nil)]]]]
        )

        expect(msg).to eql("cannot be defined")
      end
    end

    describe ":size?" do
      it "returns valid message when val is array and arg is int" do
        msg = message_compiler.visit(
          [:failure, [:numbers, [:key, [:numbers, p(:size?, 3, [1])]]]]
        )

        expect(msg).to eql("size must be 3")
      end

      it "returns valid message when val is array and arg is range" do
        msg = message_compiler.visit(
          [:failure, [:numbers, [:key, [:numbers, p(:size?, 3..4, [1])]]]]
        )

        expect(msg).to eql("size must be within 3 - 4")
      end

      it "returns valid message when arg is int" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:size?, 3, "ab")]]]]
        )

        expect(msg).to eql("length must be 3")
      end

      it "returns valid message when arg is range" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:size?, 3..4, "ab")]]]]
        )

        expect(msg).to eql("length must be within 3 - 4")
      end

      it "handles 'num' and 'size' interchangeably as interpolated arguments" do
        messages = Dry::Schema::Messages::YAML.build.merge(
          pl: {
            dry_schema: {
              errors: {
                size?: {
                  arg: {
                    default: "długość musi być równa %{num}",
                    range: "długość musi być między %{num_left} a %{size_right}"
                  }
                }
              }
            }
          }
        )
        message_compiler = Dry::Schema::MessageCompiler.new(messages).with(locale: :pl)
        range_error_message = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:size?, 3..4, "ab")]]]]
        )

        single_value_error_message = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:size?, 5, "ab")]]]]
        )

        expect(range_error_message).to eql("długość musi być między 3 a 4")
        expect(single_value_error_message).to eql("długość musi być równa 5")
      end
    end

    describe ":str?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:str?, 3)]]]]
        )

        expect(msg).to eql("must be a string")
      end
    end

    describe ":bool?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:num, [:key, [:num, p(:bool?, 3)]]]]
        )

        expect(msg).to eql("must be boolean")
      end
    end

    describe ":format?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:str, [:key, [:str, p(:format?, /^F/, "Bar")]]]]
        )

        expect(msg).to eql("is in invalid format")
      end
    end

    describe ":number?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:str, [:key, [:str, p(:number?, "not a number")]]]]
        )

        expect(msg).to eql("must be a number")
      end
    end

    describe ":odd?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:str, [:key, [:str, p(:odd?, 1)]]]]
        )

        expect(msg).to eql("must be odd")
      end
    end

    describe ":even?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:str, [:key, [:str, p(:even?, 2)]]]]
        )

        expect(msg).to eql("must be even")
      end
    end

    describe ":is_eql?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:str, [:key, [:str, p(:is_eql?, "Bar", "Foo")]]]]
        )

        expect(msg).to eql("must be equal to Bar")
      end
    end

    describe ":not_eql?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:str, [:key, [:str, p(:not_eql?, "Foo", "Foo")]]]]
        )

        expect(msg).to eql("must not be equal to Foo")
      end
    end

    describe ":type?" do
      it "returns valid message" do
        msg = message_compiler.visit(
          [:failure, [:age, [:key, [:age, p(:type?, Integer, "1")]]]]
        )

        expect(msg).to eql("must be Integer")
      end
    end
  end
end
