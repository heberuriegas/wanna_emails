TERM_TOKEN_COLORS = {
    :string => {
      :self => "\e[32m",
      :modifier => "\e[1;32m",
      :char => "\e[1;35m",
      :delimiter => "\e[1;32m",
      :escape => "\e[1;32m",
    },
    :attribute_value => "\e[32m",
    :binary => {
      :self => "\e[32m",
      :char => "\e[1;32m",
      :delimiter => "\e[1;32m",
    },
    :docstring => "\e[32m",
    :entity => "\e[32m",
    :exception => "\e[1;32m",
    :include => "\e[32m",
    :important => "\e[1;32m"
}

module CodeRay
    module Encoders
        class Terminal < Encoder
            # override old colors
            TERM_TOKEN_COLORS.each_pair do |key, value|
                TOKEN_COLORS[key] = value
            end
        end
    end
end