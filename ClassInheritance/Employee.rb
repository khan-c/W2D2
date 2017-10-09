class Employee

  attr_reader :salary, :name

  def initialize(name, title, salary, boss)
    @name = name
    @title = title
    @salary = salary
    @boss = boss
    @boss.add_sub_employee(self)
  end

  def bonus(multiplier)
    @salary * multiplier
  end
end

class Manager < Employee

  attr_accessor :employees

  def initialize(name, title, salary, boss = nil)
    super
  end

  def bonus(multiplier)
    total_sub_employee_salary = 0
    employees.each do |employee|
      total_sub_employee_salary += employee.salary

      find_subs(employee).each do |sub_e|
        total_sub_employee_salary += sub_e.salary
      end
    end

    total_sub_employee_salary * multiplier
  end

  def show_employees
    employee_str = ""
    employees.each do |employee|
      employee_str << employee.name + " "
    end
    employee_str
  end

  def add_sub_employee(sub_e)
    @employees << sub_e
  end

  def find_subs(employee)
    return [] unless employee.is_a?(Manager)

    all_employees = []
    employee.employees.each do |emp|
      all_employees += find_subs(emp) + [emp]
    end

    all_employees
  end
end
