defmodule Writer do
  @moduledoc """
  This module provides functions for managing Employee data in a JSON file.

  ## Special Symbols
  - `defmodule`: Defines a new module
  - `@moduledoc`: Provides documentation for the module
  """

  alias Empresa.Employee

  @doc """
  Writes an Employee struct to a JSON file.

  ## Parameters
  - `employee`: An Empresa.Employee struct to be written
  - `filename`: String, the name of the JSON file to write to (optional, default: "employees.json")

  ## Returns
  - `:ok` if the write operation is successful
  - `{:error, term()}` if an error occurs

  ## Examples
      iex> employee = Empresa.Employee.new("Jane Doe", "Manager")
      iex> Writer.write_employee(employee)
      :ok
  """
  @spec write_employee(Employee.t(), String.t()) :: :ok | {:error, term()}
  def write_employee(%Employee{} = employee, filename \\ "employees.json") do
    employees = read_employees(filename)
    new_id = get_next_id(employees)
    updated_employee = Map.put(employee, :id, new_id)
    updated_employees = [updated_employee | employees]

    json_data = Jason.encode!(updated_employees, pretty: true)
    File.write(filename, json_data)
  end

  @doc """
  Reads existing employees from the JSON file.

  ## Parameters
  - `filename`: String, the name of the JSON file to read from

  ## Returns
  - List of Employee structs

  ## Examples
      iex> Writer.read_employees("employees.json")
      [%Empresa.Employee{...}, ...]
  """
  @spec read_employees(String.t()) :: [Employee.t()]
  defp read_employees(filename) do
    case File.read(filename) do
      {:ok, contents} ->
        Jason.decode!(contents, keys: :atoms)
        |> Enum.map(&struct(Employee, &1))
      {:error, :enoent} -> []
    end
  end

  @doc """
  Generates the next available ID for a new employee.

  ## Parameters
  - `employees`: List of existing Employee structs

  ## Returns
  - Integer, the next available ID

  ## Examples
      iex> employees = [%Empresa.Employee{id: 1, ...}, %Empresa.Employee{id: 2, ...}]
      iex> Writer.get_next_id(employees)
      3
  """
  @spec get_next_id([Employee.t()]) :: integer()
  defp get_next_id(employees) do
    employees
    |> Enum.map(& &1.id)
    |> Enum.max(fn -> 0 end)
    |> Kernel.+(1)
  end

  @doc """
  Updates an existing Employee in the JSON file.

  ## Parameters
  - `employee`: An Empresa.Employee struct to be updated (must have a valid ID)
  - `filename`: String, the name of the JSON file to write to (optional, default: "employees.json")

  ## Returns
  - `:ok` if the update operation is successful
  - `{:error, term()}` if an error occurs

  ## Examples
      iex> updated_employee = %Empresa.Employee{id: 1, name: "Jane Doe", position: "Director"}
      iex> Writer.update_employee(updated_employee)
      :ok
  """
  @spec update_employee(Employee.t(), String.t()) :: :ok | {:error, term()}
  def update_employee(%Employee{id: id} = employee, filename \\ "employees.json") do
    employees = read_employees(filename)
    updated_employees =
      employees
      |> Enum.map(fn emp ->
           if emp.id == id, do: employee, else: emp
         end)

    json_data = Jason.encode!(updated_employees, pretty: true)
    File.write(filename, json_data)
  end

  @doc """
  Deletes an Employee by ID from the JSON file.

  ## Parameters
  - `id`: Integer, the ID of the Employee to be deleted
  - `filename`: String, the name of the JSON file to write to (optional, default: "employees.json")

  ## Returns
  - `:ok` if the delete operation is successful
  - `{:error, term()}` if an error occurs

  ## Examples
      iex> Writer.delete_employee(1)
      :ok
  """
  @spec delete_employee(integer(), String.t()) :: :ok | {:error, term()}
  def delete_employee(id, filename \\ "employees.json") do
    employees = read_employees(filename)
    updated_employees = Enum.reject(employees, fn emp -> emp.id == id end)
    json_data = Jason.encode!(updated_employees, pretty: true)
    File.write(filename, json_data)
  end
end
