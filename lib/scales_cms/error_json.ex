defmodule ScalesCms.ErrorJSON do
  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".

  def render("401.json", _assigns) do
    %{
      error: "Not authorized"
    }
  end

  def render("400.json", %{msg: msg, errors: errors}) do
    %{
      error: %{
        status: 400,
        message: msg,
        errors: inspect(errors)
      }
    }
  end

  def render("400.json", %{msg: msg}) do
    %{
      error: %{
        status: 400,
        message: msg
      }
    }
  end

  def render("403.json", %{msg: msg}) do
    %{
      error: %{
        status: 403,
        message: msg
      }
    }
  end

  def render("500.json", %{msg: msg}) do
    %{
      error: %{
        status: 500,
        message: msg
      }
    }
  end

  def render("404.json", %{msg: msg}) do
    %{
      error: %{
        status: 404,
        message: msg
      }
    }
  end

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
