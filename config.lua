local env = {

  name = "santoku-test",
  version = "0.0.3-1",
  variable_prefix = "TK_TEST",
  license = "MIT",
  public = true,

  dependencies = {
    "lua >= 5.1",
  },

}

env.homepage = "https://github.com/treadwelllane/lua-" .. env.name
env.tarball = env.name .. "-" .. env.version .. ".tar.gz"
env.download = env.homepage .. "/releases/download/" .. env.version .. "/" .. env.tarball

return {
  env = env
}
