---@diagnostic disable: duplicate-set-field

-- This is to prevent a small undefined behavior in Lua
---@diagnostic disable-next-line: redundant-parameter
setmetatable(_G, {
	---@diagnostic disable-next-line: redundant-parameter, unused-local
	__index = function(T, k, v)
		error("Called non-existing variable")
	end,
})

_G.utils = require("./libs/utils.lua")
_G.validate_table = require("./libs/table_schema.lua")
_G.import = require("./libs/import.lua")

-- MARK: Load envs

---@type fun(file_path: string)
---@diagnostic disable-next-line: undefined-global
_G.dotenv_load = astra_internal__dotenv_load
dotenv_load(".env")
dotenv_load(".env.production")
dotenv_load(".env.prod")
dotenv_load(".env.development")
dotenv_load(".env.dev")
dotenv_load(".env.test")
dotenv_load(".env.local")

---@diagnostic disable-next-line: undefined-global
os.getenv = astra_internal__getenv
---Sets the environment variable.
---
---NOT SAFE WHEN USED IN MULTITHREADING ENVIRONMENT
---@diagnostic disable-next-line: undefined-global
os.setenv = astra_internal__setenv

-- MARK: Astra

_G.Astra = {
	version = "0.0.0",
	hostname = "127.0.0.1",
	--- Enable or disable compression
	compression = false,
	port = 8080,
	--- Contains all of the route details
	routes = {},
}

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias callback fun(request: Request, response: Response): any

---@class RouteConfiguration
---@diagnostic disable-next-line: duplicate-doc-field
---@field body_limit? number

---@param path string The URL path for the request.
---@param callback callback A function that will be called when the request is made.
---@param config? RouteConfiguration
function Astra:get(path, callback, config)
	table.insert(self.routes, { path = path, method = "get", func = callback, config = config or {} })
end

---@param path string The URL path for the request.
---@param callback callback A function that will be called when the request is made.
---@param config? RouteConfiguration
function Astra:post(path, callback, config)
	table.insert(self.routes, { path = path, method = "post", func = callback, config = config or {} })
end

---@param path string The URL path for the request.
---@param callback callback A function that will be called when the request is made.
---@param config? RouteConfiguration
function Astra:put(path, callback, config)
	table.insert(self.routes, { path = path, method = "put", func = callback, config = config or {} })
end

---@param path string The URL path for the request.
---@param callback callback A function that will be called when the request is made.
---@param config? RouteConfiguration
function Astra:delete(path, callback, config)
	table.insert(self.routes, { path = path, method = "delete", func = callback, config = config or {} })
end

---@param path string The URL path for the request.
---@param callback callback A function that will be called when the request is made.
---@param config? RouteConfiguration
function Astra:options(path, callback, config)
	table.insert(self.routes, { path = path, method = "options", func = callback, config = config or {} })
end

---@param path string The URL path for the request.
---@param callback callback A function that will be called when the request is made.
---@param config? RouteConfiguration
function Astra:patch(path, callback, config)
	table.insert(self.routes, { path = path, method = "patch", func = callback, config = config or {} })
end

---@param path string The URL path for the request.
---@param callback callback A function that will be called when the request is made.
---@param config? RouteConfiguration
function Astra:trace(path, callback, config)
	table.insert(self.routes, { path = path, method = "trace", func = callback, config = config or {} })
end

---
---Registers a static folder to serve
---@param path string The URL path for the request.
---@param serve_path string The directory path relatively
---@param config? RouteConfiguration
function Astra:static_dir(path, serve_path, config)
	table.insert(
		self.routes,
		{ path = path, method = "static_dir", func = function() end, static_dir = serve_path, config = config or {} }
	)
end

---
---Registers a static file to serve
---@param path string The URL path for the request.
---@param serve_path string The directory path relatively
---@param config? RouteConfiguration
function Astra:static_file(path, serve_path, config)
	table.insert(
		self.routes,
		{ path = path, method = "static_file", func = function() end, static_file = serve_path, config = config or {} }
	)
end

---
---Runs the Astra server
function Astra:run()
	---@diagnostic disable-next-line: undefined-global
	astra_internal__start_server()
end

-- MARK: Internal

---
--- Represents an HTTP body.
---@class Body
---@field text fun(): string Returns the body as text
---@field json fun(): table Returns the body parsed as JSON -> Lua Table

---
--- Represents a multipart.
---@class Multipart
---@field save_file fun(multipart: Multipart, file_path: string | nil): string | nil Saves the multipart into disk

---
--- Represents an HTTP request.
---@class Request
---@field method fun(request: Request): string Returns the HTTP method (e.g., "GET", "POST").
---@field uri fun(request: Request): string Returns the URI of the request.
---@field queries fun(request: Request): table Returns the query list.
---@field headers fun(request: Request): table Returns a table containing the headers of the request.
---@field body fun(request: Request): Body|nil Returns the body of the request, which can be a table or a string.
---@field multipart fun(request: Request): Multipart|nil Returns a multipart if available.
---@field get_cookie fun(request: Request, name: string): Cookie Returns a cookie
---@field new_cookie fun(request: Request, name: string, value: string): Cookie Returns a cookie

---
--- Represents an HTTP response.
---@class Response
---@field set_status_code fun(response: Response, new_status_code: number) Sets the HTTP status code of the response
---@field set_header fun(response: Response, key: string, value: string) Sets a header
---@field get_headers fun(response: Response): table|nil Returns the entire headers list that so far has been set for the response
---@field remove_header fun(response: Response, key: string) Removes a header from the headers list
---@field set_cookie fun(response: Response, cookie: Cookie) Sets a cookie
---@field remove_cookie fun(response: Response, cookie: Cookie) Removes a cookie from the list

-- MARK: FileIO

---@class FileType
---@field is_file fun(file_type: FileType): boolean
---@field is_dir fun(file_type: FileType): boolean
---@field is_symlink fun(file_type: FileType): boolean

---@class DirEntry
---@field file_name fun(dir_entry: DirEntry): string Returns the file_name of the entry
---@field file_type fun(dir_entry: DirEntry): FileType
---@field path fun(dir_entry: DirEntry): string Returns the path of each entry in the list

---@class FileMetadata
---@field last_accessed fun(file_metadata: FileMetadata): number
---@field created_at fun(file_metadata: FileMetadata): number
---@field last_modified fun(file_metadata: FileMetadata): number
---@field file_type fun(file_metadata: FileMetadata): FileType
---@field file_permissions fun(file_metadata: FileMetadata): FileIOPermissions

---@class FileIOPermissions
---@field is_readonly fun(file_io_permissions: FileIOPermissions): boolean
---@field set_readonly fun(file_io_permissions: FileIOPermissions, value: boolean)

-- MARK: Cookie

---@class Cookie
---@field set_name fun(cookie: Cookie, name: string)
---@field set_value fun(cookie: Cookie, value: string)
---@field set_domain fun(cookie: Cookie, domain: string)
---@field set_path fun(cookie: Cookie, path: string)
---@field set_expiration fun(cookie: Cookie, expiration: number)
---@field set_http_only fun(cookie: Cookie, http_only: boolean)
---@field set_max_age fun(cookie: Cookie, max_age: number)
---@field set_permanent fun(cookie: Cookie)
---@field get_name fun(cookie: Cookie): string?
---@field get_value fun(cookie: Cookie): string?
---@field get_domain fun(cookie: Cookie): string?
---@field get_path fun(cookie: Cookie): string?
---@field get_expiration fun(cookie: Cookie): number?
---@field get_http_only fun(cookie: Cookie): boolean?
---@field get_max_age fun(cookie: Cookie): number?

--- @START_REMOVING_RUNTIME

_G.AstraIO = {
	---Returns the metadata of a file or directory
	---@param path string
	---@return FileMetadata
	get_metadata = function(path)
		return {}
	end,

	---Returns the content of the directory
	---@param path string Path to the file
	---@return DirEntry[]
	read_dir = function(path)
		return {}
	end,

	---Returns the path of the current directory
	---@return string
	get_current_dir = function()
		return ""
	end,

	---Returns the path of the current running script
	---@return string
	get_script_path = function()
		return ""
	end,

	---Changes the current directory
	---@param path string Path to the directory
	change_dir = function(path) end,

	---Checks if a path exists
	---@param path string Path to the file or directory
	---@return boolean
	exists = function(path)
		return false
	end,

	---Creates a directory
	---@param path string Path to the directory
	create_dir = function(path) end,

	---Creates a directory recursively
	---@param path string Path to the directory
	create_dir_all = function(path) end,

	---Removes a file
	---@param path string Path to the file
	remove = function(path) end,

	---Removes a directory
	---@param path string Path to the directory
	remove_dir = function(path) end,

	---Removes a directory recursively
	---@param path string Path to the directory
	remove_dir_all = function(path) end,
}
--- @END_REMOVING_RUNTIME
