require 'rails_helper'
require 'helpers'

RSpec.configure do |c|
  c.include Helpers
end

RSpec.describe Record, :type => :model do
  let(:identifier) {
    Identifier.new(identifier: "foo")
  }
  subject {
    described_class.new(row: 0, email: "me@mail.com",
                        phone: "555.234.5678",
                        first: "Firstname", last: "Lastname",
                        identifier: identifier)
  }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "requires identifier" do
    subject.identifier = nil
    expect(subject).to_not be_valid
  end
  
  it "requires integer row" do
    subject.row = nil
    expect(subject).to_not be_valid
  end

  it "requires email present" do
    subject.email = ""
    expect(subject).to_not be_valid
  end

  it "accepts valid email addresses" do
    valid = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
               first.last@foo.jp me+bobbymcgee@baz.cn]
    valid.each { |email|
      subject.email = email
      expect(subject).to be_valid, "#{email} should be valid"
    }
  end

  it "rejects invalid email addresses" do
    invalid = %w[user@example,com user_at_foo.org user.name@example.
                 foo@bar_baz.com foo@bar+baz.com foo@bar..com foo@b
                 foo@bar.b]
    invalid.each { |_email|
      subject.email = _email
      expect(subject).to_not be_valid, "#{_email} should not be valid"
    }
  end

  it "requires email.length <= 255" do
    suffix = "@me.com"
    subject.email = "a"*(255 - suffix.length) + suffix
    expect(subject).to be_valid
    subject.email = "a"+subject.email
    expect(subject).to_not be_valid
  end

  it "requires phone" do
    subject.phone = ""
    expect(subject).to_not be_valid
  end

  it "only accepts phone with valid characters" do
    valid = "9876543210-.()"
    subject.phone = valid
    expect(subject).to be_valid

    each_printable_char_except_in(valid) { |ch|
      subject.phone = valid + ch
      expect(subject).to_not be_valid, "#{ch} should not be a valid character"
    }
  end

  it "only accepts phone numbers with 10 digits" do
    subject.phone = "5" * 10
    expect(subject).to be_valid
    subject.phone += "5" * 9
    expect(subject).to_not be_valid
    subject.phone = "5" * 11
    expect(subject).to_not be_valid
  end

  it "ignores symbols in counting phone digits" do
    subject.phone = "5(4)3.4-4-(5-6-890---)(."
    expect(subject).to be_valid
  end

  def name_length_boundary_check(field)
    subject[field] = "a"
    expect(subject).to_not be_valid
    subject[field] = "aa"
    expect(subject).to be_valid
    subject[field] = "a" * 255
    expect(subject).to be_valid
    subject[field] += "a"
    expect(subject).to_not be_valid
  end

  it "requires first.length in [2..255]" do
    name_length_boundary_check(:first)
  end

  it "requires last.length in [2..255]" do
    name_length_boundary_check(:last)
  end

  def name_alpha_check(field)
    valid = (('a'..'z').to_a + ('A'..'Z').to_a).join
    subject[field] = valid
    expect(subject).to be_valid
  
    each_printable_char_except_in(valid) { |ch|
      subject[field] = valid + ch
      expect(subject).to_not be_valid, "#{ch} should not be a valid character"
    }
  end

  it "requires first comprised of alpha characters" do
    name_alpha_check(:first)
  end

  it "requires last comprised of alpha characters" do
    name_alpha_check(:last)
  end

  it "only accepts last if first is specified" do
    subject.first = ""
    expect(subject).to_not be_valid
  end
end