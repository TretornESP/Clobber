from sqlitedict import SqliteDict

class DBManager():
    def __init__(self, store):
        self._db = SqliteDict(store, autocommit=True)
        self.commands_cache = {}
    def add(self, command):
        if self.get_command(command.get_name()) != None:
            return False
        self._db[command.get_name()] = command
        return True
    def update(self, command):
        self.add(command)
    def remove(self, command):
        del self._db[command.get_name()]
    def empty(self):
        self.commands_cache = {}
        self._db.clear()
    def count(self):
        return len(self._db)
    def get_command(self, name):
        if name not in self.commands_cache:
            try:
                self.commands_cache[name] = self._db[name]
            except KeyError:
                return None
        return self.commands_cache[name]
    def get_all_commands(self):
        list = []
        for key, val in self._db.iteritems():
            list.append(key)
        return list
