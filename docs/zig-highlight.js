/**
 * Zig language definition for highlight.js
 * Custom implementation for libxev-http documentation
 */

// Register Zig language with highlight.js
if (typeof hljs !== 'undefined') {
    hljs.registerLanguage('zig', function(hljs) {
        return {
            name: 'Zig',
            aliases: ['zig'],
            keywords: {
                keyword: [
                    'const', 'var', 'fn', 'pub', 'try', 'defer', 'if', 'else',
                    'while', 'for', 'switch', 'struct', 'enum', 'union', 'error',
                    'anyerror', 'void', 'return', 'break', 'continue', 'unreachable',
                    'comptime', 'inline', 'export', 'extern', 'packed', 'align',
                    'linksection', 'callconv', 'noalias', 'async', 'await', 'suspend',
                    'resume', 'nosuspend', 'allowzero', 'volatile'
                ].join(' '),
                built_in: [
                    'std', 'u8', 'u16', 'u32', 'u64', 'u128', 'i8', 'i16', 'i32',
                    'i64', 'i128', 'f16', 'f32', 'f64', 'f80', 'f128', 'bool',
                    'usize', 'isize', 'c_int', 'c_uint', 'c_char', 'c_void',
                    'c_short', 'c_ushort', 'c_long', 'c_ulong', 'c_longlong',
                    'c_ulonglong', 'c_longdouble', 'anyopaque', 'type', 'noreturn'
                ].join(' '),
                literal: 'true false null undefined'
            },
            contains: [
                // Line comments
                {
                    className: 'comment',
                    begin: '//',
                    end: '$',
                    relevance: 0
                },
                // Block comments
                {
                    className: 'comment',
                    begin: '/\\*',
                    end: '\\*/',
                    relevance: 0
                },
                // Strings
                {
                    className: 'string',
                    variants: [
                        {
                            begin: '"',
                            end: '"',
                            contains: [
                                {
                                    begin: '\\\\.',
                                    relevance: 0
                                }
                            ]
                        },
                        {
                            begin: "'",
                            end: "'",
                            contains: [
                                {
                                    begin: '\\\\.',
                                    relevance: 0
                                }
                            ]
                        },
                        // Multi-line strings
                        {
                            begin: '\\\\\\\\',
                            end: '$',
                            relevance: 0
                        }
                    ]
                },
                // Numbers
                {
                    className: 'number',
                    variants: [
                        // Hex
                        {
                            begin: '\\b0x[0-9a-fA-F]+\\b'
                        },
                        // Binary
                        {
                            begin: '\\b0b[01]+\\b'
                        },
                        // Octal
                        {
                            begin: '\\b0o[0-7]+\\b'
                        },
                        // Decimal with optional exponent
                        {
                            begin: '\\b\\d+(\\.\\d+)?([eE][+-]?\\d+)?\\b'
                        }
                    ]
                },
                // Functions
                {
                    className: 'function',
                    beginKeywords: 'fn',
                    end: '\\(',
                    excludeEnd: true,
                    contains: [
                        {
                            className: 'title',
                            begin: '[a-zA-Z_][a-zA-Z0-9_]*',
                            relevance: 0
                        }
                    ]
                },
                // Built-in functions and macros
                {
                    className: 'meta',
                    begin: '@[a-zA-Z_][a-zA-Z0-9_]*',
                    relevance: 10
                },
                // Type annotations
                {
                    className: 'type',
                    begin: '\\b[A-Z][a-zA-Z0-9_]*\\b',
                    relevance: 0
                },
                // Operators
                {
                    className: 'operator',
                    begin: '(\\+|\\-|\\*|/|%|==|!=|<|>|<=|>=|and|or|!|&|\\||\\^|<<|>>|=|\\+=|\\-=|\\*=|/=|%=|&=|\\|=|\\^=|<<=|>>=)',
                    relevance: 0
                }
            ],
            illegal: '</'
        };
    });

    // Initialize highlighting after DOM is loaded
    document.addEventListener('DOMContentLoaded', function() {
        hljs.highlightAll();
    });
}
