# frozen_string_literal: true

class CreateDecidimCentersRoles < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_centers_roles do |t|
      t.references :decidim_organization, foreign_key: true, index: true
      t.jsonb :title, null: false
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
