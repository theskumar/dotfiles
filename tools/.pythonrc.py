def print_sql(qs):
    import sqlparse
    try:
        import pygments
        from pygments.lexers import SqlLexer
        from pygments.formatters import TerminalTrueColorFormatter
    except ImportError:
        pygments = None

    sql = sqlparse.format(str(qs.query), reindent=True, keyword_case='upper')
    if pygments:
        sql = pygments.highlight(sql, SqlLexer(), TerminalTrueColorFormatter(style='monokai'))
    print(sql)
