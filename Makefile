# Copyright (c) 2009-2010 Satoshi Nakamoto
# Distributed under the MIT/X11 software license, see the accompanying
# file license.txt or http://www.opensource.org/licenses/mit-license.php.


INCLUDEPATHS= \
 -I"/usr/local/include/wx-2.9" \
 -I"/usr/include/db4.8" \
 -I"/usr/local/lib/wx/include/gtk2-unicode-debug-static-2.9"

# for wxWidgets 2.9.1, add -l Xxf86vm
WXLIBS= \
 -Wl,-Bstatic \
   -l wx_gtk2ud-2.9 \
 -Wl,-Bdynamic \
   -l gtk-x11-2.0 \
   -l SM

# for boost 1.37, add -mt to the boost libraries
LIBS= \
   -l boost_system \
   -l boost_filesystem \
   -l boost_program_options \
   -l boost_thread \
   -l db_cxx \
   -l ssl \
   -l crypto \
   -l pthread \
   -l z \
   -l dl

DEFS=-DNOPCH -DFOURWAYSSE2 -DUSE_SSL
#DEBUGFLAGS=-g -D__WXDEBUG__
CFLAGS=-O2 -Wno-invalid-offsetof -Wformat $(DEBUGFLAGS) $(DEFS) $(INCLUDEPATHS)
HEADERS=headers.h strlcpy.h serialize.h uint256.h util.h key.h bignum.h base58.h \
    script.h db.h net.h irc.h main.h rpc.h uibase.h ui.h noui.h init.h

OBJS= \
    obj/util.o \
    obj/script.o \
    obj/db.o \
    obj/net.o \
    obj/irc.o \
    obj/main.o \
    obj/rpc.o \
    obj/init.o \
    cryptopp/obj/sha.o \
    cryptopp/obj/cpu.o


all: bitcoind


obj/%.o: %.cpp $(HEADERS)
	g++ -c $(CFLAGS) -DGUI -o $@ $<

cryptopp/obj/%.o: cryptopp/%.cpp
	g++ -c $(CFLAGS) -O3 -o $@ $<

obj/sha256.o: sha256.cpp
	g++ -c $(CFLAGS) -msse2 -O3 -march=nocona -o $@ $<

bitcoin: $(OBJS) obj/ui.o obj/uibase.o obj/sha256.o
	g++ $(CFLAGS) -o $@ $^ $(WXLIBS) $(LIBS)


obj/nogui/%.o: %.cpp $(HEADERS)
	g++ -c $(CFLAGS) -o $@ $<

bitcoind: $(OBJS:obj/%=obj/nogui/%) obj/sha256.o
	g++ $(CFLAGS) -o $@ $^ $(LIBS)


clean:
	-rm -f obj/*.o
	-rm -f obj/nogui/*.o
	-rm -f cryptopp/obj/*.o
	-rm -f headers.h.gch
