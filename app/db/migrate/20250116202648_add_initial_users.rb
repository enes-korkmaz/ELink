class AddInitialUsers < ActiveRecord::Migration[7.2]
  def up
    # Check for missing or empty environment variables
    check_env_variable("EMPLOYEE_USERNAME")
    check_env_variable("EMPLOYEE_PASSWORD")
    check_env_variable("INTERN_USERNAME")
    check_env_variable("INTERN_PASSWORD")

    # Proceed with user creation if all checks pass
    User.create!(
      username: ENV["EMPLOYEE_USERNAME"],
      password_digest: BCrypt::Password.create(ENV["EMPLOYEE_PASSWORD"]),
      role: 'employee',
      expert: nil
    )

    User.create!(
      username: ENV["INTERN_USERNAME"],
      password_digest: BCrypt::Password.create(ENV["INTERN_PASSWORD"]),
      role: 'intern',
      expert: nil
    )
  end

  def down
    # Cleanup - delete users created in the 'up' method
    # This can be reversed using `rails db:rollback` to remove users with the roles 'employee' and 'intern'.
    User.where(role: [ 'employee', 'intern' ]).delete_all
  end

  private

  # Helper method to check that an environment variable is present and non-blank
  def check_env_variable(variable_name)
    value = ENV[variable_name]

    if value.nil? || value.strip.empty?
      raise "Environment variable '#{variable_name}' is missing or empty."
    end
  end
end
