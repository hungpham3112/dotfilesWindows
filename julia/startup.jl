ENV["JULIA_NUM_THREADS"] = 8
ENV["EDITOR"] = "vim"
ENV["PYTHON"] = "python"

atreplinit() do repl
    try
        @eval using OhMyREPL
    catch e
        @warn "error while importing OhMyREPL" e
    end
end
try
    using OhMyREPL
    OhMyREPL.enable_autocomplete_brackets(true)
    OhMyREPL.enable_highlight_markdown(true)
    OhMyREPL.enable_fzf(true)
catch e
    @warn "error while use OhMyREPL function" e
end

try
    @eval using Revise
catch e
    @warn "Error initializing Revise" exception=(e, catch_backtrace())
end
