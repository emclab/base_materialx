# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :base_materialx_part, :class => 'BaseMaterialx::Part' do
    name "MyString"
    spec "MyString"
    part_num "MyString"
    unit "MyString"
    desp "MyText"
    preferred_mfr "MyText"
    preferred_supplier "MyText"
    category_id 1
    sub_category_id 1
    #last_updated_by_id 1
    wf_state "MyString"
    active true
  end
end
