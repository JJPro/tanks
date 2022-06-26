defmodule TanksWeb.Router do
  use TanksWeb, :router

  import TanksWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TanksWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # TODO delete this route if unused
  scope "/", TanksWeb do
    pipe_through :browser

    get "/", PageController, :index
  end


  # Other scopes may use custom stacks.
  # scope "/api", TanksWeb do
  #   pipe_through :api
  # end

  ## Authentication routes

  scope "/auth", TanksWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/register", AuthController, :register_view
    post "/register", AuthController, :register_request
    get "/login", AuthController, :login_view
    post "/login", AuthController, :login_request
  end

  scope "/", TanksWeb do
    pipe_through [:browser, :require_authenticated_user]

    delete "/log_out", AuthController, :logout_request
    resources "/users", UserController, only: [:show, :edit, :update]
  end

end
