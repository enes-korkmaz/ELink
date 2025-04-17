class AddLanguagesToDb < ActiveRecord::Migration[7.2]
  def up
    Language.create!([
      { language: "English", language_code: "en" },
      { language: "German", language_code: "de" },
      { language: "Chinese", language_code: "zh" }
    ])
  end

  def down
    Language.where(language_code: %w[en de zh]).delete_all
  end
end
