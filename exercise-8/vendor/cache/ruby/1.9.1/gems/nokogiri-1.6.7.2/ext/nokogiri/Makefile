
SHELL = /bin/sh

# V=0 quiet, V=1 verbose.  other values don't work.
V = 0
Q1 = $(V:1=)
Q = $(Q1:0=@)
n=$(NULLCMD)
ECHO1 = $(V:1=@$n)
ECHO = $(ECHO1:0=@echo)

#### Start of system configuration section. ####

srcdir = .
topdir = /usr/include/ruby-1.9.1
hdrdir = /usr/include/ruby-1.9.1
arch_hdrdir = /usr/include/ruby-1.9.1/$(arch)
VPATH = $(srcdir):$(arch_hdrdir)/ruby:$(hdrdir)/ruby
prefix = $(DESTDIR)/usr
rubylibprefix = $(libdir)/$(RUBY_BASE_NAME)
exec_prefix = $(prefix)
vendorhdrdir = $(rubyhdrdir)/vendor_ruby
sitehdrdir = $(rubyhdrdir)/site_ruby
rubyhdrdir = $(includedir)/$(RUBY_BASE_NAME)-$(ruby_version)
vendordir = $(DESTDIR)/usr/lib/ruby/vendor_ruby
sitedir = $(DESTDIR)/usr/local/lib/site_ruby
ridir = $(datarootdir)/$(RI_BASE_NAME)
mandir = $(prefix)/share/man
localedir = $(datarootdir)/locale
libdir = $(exec_prefix)/lib
psdir = $(docdir)
pdfdir = $(docdir)
dvidir = $(docdir)
htmldir = $(docdir)
infodir = $(prefix)/share/info
docdir = $(datarootdir)/doc/$(PACKAGE)
oldincludedir = $(DESTDIR)/usr/include
includedir = $(prefix)/include
localstatedir = $(DESTDIR)/var
sharedstatedir = $(prefix)/com
sysconfdir = $(DESTDIR)/etc
datadir = $(datarootdir)
datarootdir = $(prefix)/share
libexecdir = $(prefix)/lib/ruby1.9.1
sbindir = $(exec_prefix)/sbin
bindir = $(exec_prefix)/bin
rubylibdir = $(rubylibprefix)/$(ruby_version)
archdir = $(rubylibdir)/$(arch)
sitelibdir = $(sitedir)/$(ruby_version)
sitearchdir = $(sitelibdir)/$(sitearch)
vendorlibdir = $(vendordir)/$(ruby_version)
vendorarchdir = $(vendorlibdir)/$(sitearch)

NULLCMD = :

CC = gcc
CXX = g++
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static
empty =
OUTFLAG = -o $(empty)
COUTFLAG = -o $(empty)

RUBY_EXTCONF_H = 
cflags   =  $(optflags) $(debugflags) $(warnflags)
optflags = -O3
debugflags = -ggdb
warnflags = -Wall -Wextra -Wno-unused-parameter -Wno-parentheses -Wno-long-long -Wno-missing-field-initializers -Wpointer-arith -Wwrite-strings -Wdeclaration-after-statement -Wimplicit-function-declaration
CFLAGS   = -fPIC -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wall -fno-strict-aliasing -fPIC  -g -DXP_UNIX -Wall -Wcast-qual -Wwrite-strings -Wconversion -Wmissing-noreturn -Winline -DNOKOGIRI_USE_PACKAGED_LIBRARIES $(ARCH_FLAG)
INCFLAGS = -I. -I$(arch_hdrdir) -I$(hdrdir)/ruby/backward -I$(hdrdir) -I$(srcdir)
DEFS     = 
CPPFLAGS = -DHAVE_XMLPARSEDOC -DHAVE_XSLTPARSESTYLESHEETDOC -DHAVE_EXSLTFUNCREGISTER -DHAVE_XMLHASFEATURE -DHAVE_XMLFIRSTELEMENTCHILD -DHAVE_XMLRELAXNGSETPARSERSTRUCTUREDERRORS -DHAVE_XMLRELAXNGSETPARSERSTRUCTUREDERRORS -DHAVE_XMLRELAXNGSETVALIDSTRUCTUREDERRORS -DHAVE_XMLSCHEMASETVALIDSTRUCTUREDERRORS -DHAVE_XMLSCHEMASETPARSERSTRUCTUREDERRORS -I/home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxslt/1.1.28/include -I/home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxml2/2.9.2/include/libxml2 -I/home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxml2/2.9.2/include/libxml2 -D_FORTIFY_SOURCE=2 $(DEFS) $(cppflags) "-DNOKOGIRI_LIBXML2_PATH=\"/home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxml2/2.9.2\"" "-DNOKOGIRI_LIBXML2_PATCHES=\"0001-Revert-Missing-initialization-for-the-catalog-module.patch 0002-Fix-missing-entities-after-CVE-2014-3660-fix.patch 0003-Stop-parsing-on-entities-boundaries-errors.patch 0004-Cleanup-conditional-section-error-handling.patch 0005-CVE-2015-1819-Enforce-the-reader-to-run-in-constant-.patch 0006-Another-variation-of-overflow-in-Conditional-section.patch 0007-Fix-an-error-in-previous-Conditional-section-patch.patch 0008-CVE-2015-8035-Fix-XZ-compression-support-loop.patch 0009-Updated-config.guess.patch 0010-Fix-parsering-short-unclosed-comment-uninitialized-access.patch 0011-Avoid-extra-processing-of-MarkupDecl-when-EOF.patch 0012-Avoid-processing-entities-after-encoding-conversion-.patch 0013-CVE-2015-7497-Avoid-an-heap-buffer-overflow-in-xmlDi.patch 0014-CVE-2015-5312-Another-entity-expansion-issue.patch 0015-Add-xmlHaltParser-to-stop-the-parser.patch 0016-Detect-incoherency-on-GROW.patch 0017-CVE-2015-7500-Fix-memory-access-error-due-to-incorre.patch 0018-CVE-2015-8242-Buffer-overead-with-HTML-parser-in-pus.patch 0019-Do-not-print-error-context-when-there-is-none.patch 0020-xmlStopParser-reset-errNo.patch 0021-Reuse-xmlHaltParser-where-it-makes-sense.patch\"" "-DNOKOGIRI_LIBXSLT_PATH=\"/home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxslt/1.1.28\"" "-DNOKOGIRI_LIBXSLT_PATCHES=\"0001-Adding-doc-update-related-to-1.1.28.patch 0002-Fix-a-couple-of-places-where-f-printf-parameters-wer.patch 0003-Initialize-pseudo-random-number-generator-with-curre.patch 0004-EXSLT-function-str-replace-is-broken-as-is.patch 0006-Fix-str-padding-to-work-with-UTF-8-strings.patch 0007-Separate-function-for-predicate-matching-in-patterns.patch 0008-Fix-direct-pattern-matching.patch 0009-Fix-certain-patterns-with-predicates.patch 0010-Fix-handling-of-UTF-8-strings-in-EXSLT-crypto-module.patch 0013-Memory-leak-in-xsltCompileIdKeyPattern-error-path.patch 0014-Fix-for-bug-436589.patch 0015-Fix-mkdir-for-mingw.patch 0016-Fix-for-type-confusion-in-preprocessing-attributes.patch 0017-Updated-config.guess.patch\""
CXXFLAGS = $(CFLAGS) -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wall -fno-strict-aliasing
ldflags  = -L. -Wl,-Bsymbolic-functions -Wl,-z,relro -L/build/buildd/ruby1.9.1-1.9.3.484/debian/lib -rdynamic -Wl,-export-dynamic
dldflags =  
ARCH_FLAG = 
DLDFLAGS = $(ldflags) $(dldflags) $(ARCH_FLAG)
LDSHARED = $(CC) -shared
LDSHAREDXX = $(CXX) -shared
AR = ar
EXEEXT = 

RUBY_BASE_NAME = ruby
RUBY_INSTALL_NAME = ruby1.9.1
RUBY_SO_NAME = ruby-1.9.1
arch = x86_64-linux
sitearch = $(arch)
ruby_version = 1.9.1
ruby = /usr/bin/ruby1.9.1
RUBY = $(ruby)
RM = rm -f
RM_RF = $(RUBY) -run -e rm -- -rf
RMDIRS = rmdir --ignore-fail-on-non-empty -p
MAKEDIRS = /bin/mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp
TOUCH = exit >

#### End of system configuration section. ####

preload = 

libpath = . $(libdir) /home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxml2/2.9.2/lib /home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxslt/1.1.28/lib
LIBPATH =  -L. -L$(libdir) -L/home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxml2/2.9.2/lib -L/home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxslt/1.1.28/lib
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 
DISTCLEANDIRS = 

extout = 
extout_prefix = 
target_prefix = /nokogiri
LOCAL_LIBS = 
LIBS = $(LIBRUBYARG_SHARED) /home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxslt/1.1.28/lib/libexslt.a -lm -ldl -lz /home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxml2/2.9.2/lib/libxml2.a /home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxslt/1.1.28/lib/libxslt.a -ldl -lm -lz /home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/ports/x86_64-pc-linux-gnu/libxml2/2.9.2/lib/libxml2.a -lpthread -lrt -ldl -lcrypt -lm   -lc 
SRCS = html_document.c html_element_description.c html_entity_lookup.c html_sax_parser_context.c html_sax_push_parser.c nokogiri.c xml_attr.c xml_attribute_decl.c xml_cdata.c xml_comment.c xml_document.c xml_document_fragment.c xml_dtd.c xml_element_content.c xml_element_decl.c xml_encoding_handler.c xml_entity_decl.c xml_entity_reference.c xml_io.c xml_libxml2_hacks.c xml_namespace.c xml_node.c xml_node_set.c xml_processing_instruction.c xml_reader.c xml_relax_ng.c xml_sax_parser.c xml_sax_parser_context.c xml_sax_push_parser.c xml_schema.c xml_syntax_error.c xml_text.c xml_xpath_context.c xslt_stylesheet.c
OBJS = html_document.o html_element_description.o html_entity_lookup.o html_sax_parser_context.o html_sax_push_parser.o nokogiri.o xml_attr.o xml_attribute_decl.o xml_cdata.o xml_comment.o xml_document.o xml_document_fragment.o xml_dtd.o xml_element_content.o xml_element_decl.o xml_encoding_handler.o xml_entity_decl.o xml_entity_reference.o xml_io.o xml_libxml2_hacks.o xml_namespace.o xml_node.o xml_node_set.o xml_processing_instruction.o xml_reader.o xml_relax_ng.o xml_sax_parser.o xml_sax_parser_context.o xml_sax_push_parser.o xml_schema.o xml_syntax_error.o xml_text.o xml_xpath_context.o xslt_stylesheet.o
TARGET = nokogiri
TARGET_NAME = nokogiri
TARGET_ENTRY = Init_$(TARGET_NAME)
DLLIB = $(TARGET).so
EXTSTATIC = 
STATIC_LIB = 

BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR = /home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/lib$(target_prefix)
RUBYARCHDIR = /home/vagrant/project/vendor/cache/ruby/1.9.1/gems/nokogiri-1.6.7.2/lib$(target_prefix)
HDRDIR        = $(rubyhdrdir)/ruby$(target_prefix)
ARCHHDRDIR    = $(rubyhdrdir)/$(arch)/ruby$(target_prefix)

TARGET_SO     = $(DLLIB)
CLEANLIBS     = $(TARGET).so 
CLEANOBJS     = *.o  *.bak

all:    $(DLLIB)
static: $(STATIC_LIB)
.PHONY: all install static install-so install-rb
.PHONY: clean clean-so clean-rb

clean-static::
clean-rb-default::
clean-rb::
clean-so::
clean: clean-so clean-static clean-rb-default clean-rb
		-$(Q)$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES) .*.time

distclean-rb-default::
distclean-rb::
distclean-so::
distclean: clean distclean-so distclean-rb-default distclean-rb
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)
		@-$(RMDIRS) $(DISTCLEANDIRS) 2> /dev/null || true

realclean: distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)/$(DLLIB)
$(RUBYARCHDIR)/$(DLLIB): $(DLLIB)
	-$(Q)$(MAKEDIRS) $(@D)
	$(INSTALL_PROG) $(DLLIB) $(@D)
clean-static::
	-$(Q)$(RM) $(STATIC_LIB)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
pre-install-rb-default:
	$(ECHO) installing default nokogiri libraries
./.RUBYARCHDIR.time:
	$(Q) $(MAKEDIRS) $(RUBYARCHDIR)
	$(Q) $(TOUCH) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .mm .cxx .cpp .C .o

.cc.o:
	$(ECHO) compiling $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -c $<

.mm.o:
	$(ECHO) compiling $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -c $<

.cxx.o:
	$(ECHO) compiling $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -c $<

.cpp.o:
	$(ECHO) compiling $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -c $<

.C.o:
	$(ECHO) compiling $(<)
	$(Q) $(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) $(COUTFLAG)$@ -c $<

.c.o:
	$(ECHO) compiling $(<)
	$(Q) $(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) $(COUTFLAG)$@ -c $<

.m.o:
	$(ECHO) compiling $(<)
	$(Q) $(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) $(COUTFLAG)$@ -c $<

$(DLLIB): $(OBJS) Makefile
	$(ECHO) linking shared-object nokogiri/$(DLLIB)
	-$(Q)$(RM) $(@)
	$(Q) $(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)



###
html_document.o: html_document.c html_document.h nokogiri.h xml_io.h	\
  xml_document.h html_entity_lookup.h xml_node.h xml_text.h		\
  xml_cdata.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

html_element_description.o: html_element_description.c			\
 html_element_description.h nokogiri.h xml_io.h xml_document.h		\
 html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
 xml_cdata.h xml_attr.h xml_processing_instruction.h			\
 xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
 xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
 xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
 xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
 xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
 xml_syntax_error.h xml_schema.h xml_relax_ng.h xml_namespace.h		\
 xml_encoding_handler.h

html_entity_lookup.o: html_entity_lookup.c html_entity_lookup.h		\
  nokogiri.h xml_io.h xml_document.h html_document.h xml_node.h		\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

html_sax_parser_context.o: html_sax_parser_context.c			\
 html_sax_parser_context.h nokogiri.h xml_io.h xml_document.h		\
 html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
 xml_cdata.h xml_attr.h xml_processing_instruction.h			\
 xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
 xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
 xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
 xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
 xml_reader.h xslt_stylesheet.h xml_syntax_error.h xml_schema.h		\
 xml_relax_ng.h html_element_description.h xml_namespace.h		\
 xml_encoding_handler.h

nokogiri.o: nokogiri.c nokogiri.h xml_io.h xml_document.h		\
  html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
  xml_cdata.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_attr.o: xml_attr.c xml_attr.h nokogiri.h xml_io.h xml_document.h	\
  html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
  xml_cdata.h xml_processing_instruction.h xml_entity_reference.h	\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_attribute_decl.o: xml_attribute_decl.c xml_attribute_decl.h		\
  nokogiri.h xml_io.h xml_document.h html_entity_lookup.h		\
  html_document.h xml_node.h xml_text.h xml_cdata.h xml_attr.h		\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_element_decl.h xml_entity_decl.h xml_xpath_context.h		\
  xml_element_content.h xml_sax_parser_context.h xml_sax_parser.h	\
  xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_cdata.o: xml_cdata.c xml_cdata.h nokogiri.h xml_io.h		\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_comment.o: xml_comment.c xml_comment.h nokogiri.h xml_io.h		\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_node_set.h		\
  xml_dtd.h xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h	\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_document.o: xml_document.c xml_document.h nokogiri.h xml_io.h	\
  html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
  xml_cdata.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_document_fragment.o: xml_document_fragment.c			\
  xml_document_fragment.h nokogiri.h xml_io.h xml_document.h		\
  html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
  xml_cdata.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_comment.h xml_node_set.h xml_dtd.h		\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_dtd.o: xml_dtd.c xml_dtd.h nokogiri.h xml_io.h xml_document.h	\
  html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
  xml_cdata.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_attribute_decl.h xml_element_decl.h		\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_element_content.o: xml_element_content.c xml_element_content.h	\
  nokogiri.h xml_io.h xml_document.h html_entity_lookup.h		\
  html_document.h xml_node.h xml_text.h xml_cdata.h xml_attr.h		\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_sax_parser_context.h xml_sax_parser.h		\
  xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_element_decl.o: xml_element_decl.c xml_element_decl.h nokogiri.h	\
  xml_io.h xml_document.h html_entity_lookup.h html_document.h		\
  xml_node.h xml_text.h xml_cdata.h xml_attr.h				\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_entity_decl.h xml_xpath_context.h		\
  xml_element_content.h xml_sax_parser_context.h xml_sax_parser.h	\
  xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_encoding_handler.o: xml_encoding_handler.c xml_encoding_handler.h	\
  nokogiri.h xml_io.h xml_document.h html_entity_lookup.h		\
  html_document.h xml_node.h xml_text.h xml_cdata.h xml_attr.h		\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h

xml_entity_decl.o: xml_entity_decl.c xml_entity_decl.h nokogiri.h	\
  xml_io.h xml_document.h html_entity_lookup.h html_document.h		\
  xml_node.h xml_text.h xml_cdata.h xml_attr.h				\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_xpath_context.h		\
  xml_element_content.h xml_sax_parser_context.h xml_sax_parser.h	\
  xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_entity_reference.o: xml_entity_reference.c xml_entity_reference.h	\
  nokogiri.h xml_io.h xml_document.h html_entity_lookup.h		\
  html_document.h xml_node.h xml_text.h xml_cdata.h xml_attr.h		\
  xml_processing_instruction.h xml_document_fragment.h xml_comment.h	\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_io.o: xml_io.c xml_io.h nokogiri.h xml_document.h			\
  html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
  xml_cdata.h xml_attr.h xml_processing_instruction.h			\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_namespace.o: xml_namespace.c xml_namespace.h nokogiri.h xml_io.h	\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h xml_relax_ng.h			\
  html_element_description.h xml_encoding_handler.h

xml_node.o: xml_node.c xml_node.h nokogiri.h xml_io.h xml_document.h	\
  html_entity_lookup.h html_document.h xml_text.h xml_cdata.h		\
  xml_attr.h xml_processing_instruction.h xml_entity_reference.h	\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_node_set.o: xml_node_set.c xml_node_set.h nokogiri.h xml_io.h	\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_dtd.h xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h	\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_processing_instruction.o: xml_processing_instruction.c		\
 xml_processing_instruction.h nokogiri.h xml_io.h xml_document.h	\
 html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
 xml_cdata.h xml_attr.h xml_entity_reference.h xml_document_fragment.h	\
 xml_comment.h xml_node_set.h xml_dtd.h xml_attribute_decl.h		\
 xml_element_decl.h xml_entity_decl.h xml_xpath_context.h		\
 xml_element_content.h xml_sax_parser_context.h xml_sax_parser.h	\
 xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
 xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
 html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_reader.o: xml_reader.c xml_reader.h nokogiri.h xml_io.h		\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_relax_ng.o: xml_relax_ng.c xml_relax_ng.h nokogiri.h xml_io.h	\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_schema.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_sax_parser.o: xml_sax_parser.c xml_sax_parser.h nokogiri.h		\
  xml_io.h xml_document.h html_entity_lookup.h html_document.h		\
  xml_node.h xml_text.h xml_cdata.h xml_attr.h				\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_sax_parser_context.o: xml_sax_parser_context.c			\
 xml_sax_parser_context.h nokogiri.h xml_io.h xml_document.h		\
 html_entity_lookup.h html_document.h xml_node.h xml_text.h		\
 xml_cdata.h xml_attr.h xml_processing_instruction.h			\
 xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
 xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
 xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
 xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
 html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h		\
 xml_schema.h xml_relax_ng.h html_element_description.h			\
 xml_namespace.h xml_encoding_handler.h

xml_sax_push_parser.o: xml_sax_push_parser.c xml_sax_push_parser.h	\
  nokogiri.h xml_io.h xml_document.h html_entity_lookup.h		\
  html_document.h xml_node.h xml_text.h xml_cdata.h xml_attr.h		\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xml_schema.o: xml_schema.c xml_schema.h nokogiri.h xml_io.h		\
  xml_document.h html_entity_lookup.h html_document.h xml_node.h	\
  xml_text.h xml_cdata.h xml_attr.h xml_processing_instruction.h	\
  xml_entity_reference.h xml_document_fragment.h xml_comment.h		\
  xml_node_set.h xml_dtd.h xml_attribute_decl.h xml_element_decl.h	\
  xml_entity_decl.h xml_xpath_context.h xml_element_content.h		\
  xml_sax_parser_context.h xml_sax_parser.h xml_sax_push_parser.h	\
  xml_reader.h html_sax_parser_context.h xslt_stylesheet.h		\
  xml_syntax_error.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_syntax_error.o: xml_syntax_error.c xml_syntax_error.h nokogiri.h	\
  xml_io.h xml_document.h html_entity_lookup.h html_document.h		\
  xml_node.h xml_text.h xml_cdata.h xml_attr.h				\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_schema.h		\
  xml_relax_ng.h html_element_description.h xml_namespace.h		\
  xml_encoding_handler.h

xml_text.o: xml_text.c xml_text.h nokogiri.h xml_io.h xml_document.h	\
  html_entity_lookup.h html_document.h xml_node.h xml_cdata.h		\
  xml_attr.h xml_processing_instruction.h xml_entity_reference.h	\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xslt_stylesheet.h xml_syntax_error.h	\
  xml_schema.h xml_relax_ng.h html_element_description.h		\
  xml_namespace.h xml_encoding_handler.h

xml_xpath_context.o: xml_xpath_context.c xml_xpath_context.h		\
  nokogiri.h xml_io.h xml_document.h html_entity_lookup.h		\
  html_document.h xml_node.h xml_text.h xml_cdata.h xml_attr.h		\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_element_content.h xml_sax_parser_context.h xml_sax_parser.h	\
  xml_sax_push_parser.h xml_reader.h html_sax_parser_context.h		\
  xslt_stylesheet.h xml_syntax_error.h xml_schema.h xml_relax_ng.h	\
  html_element_description.h xml_namespace.h xml_encoding_handler.h

xslt_stylesheet.o: xslt_stylesheet.c xslt_stylesheet.h nokogiri.h	\
  xml_io.h xml_document.h html_entity_lookup.h html_document.h		\
  xml_node.h xml_text.h xml_cdata.h xml_attr.h				\
  xml_processing_instruction.h xml_entity_reference.h			\
  xml_document_fragment.h xml_comment.h xml_node_set.h xml_dtd.h	\
  xml_attribute_decl.h xml_element_decl.h xml_entity_decl.h		\
  xml_xpath_context.h xml_element_content.h xml_sax_parser_context.h	\
  xml_sax_parser.h xml_sax_push_parser.h xml_reader.h			\
  html_sax_parser_context.h xml_syntax_error.h xml_schema.h		\
  xml_relax_ng.h html_element_description.h xml_namespace.h		\
  xml_encoding_handler.h
all: clean-ports

clean-ports: $(DLLIB)
	-$(Q)$(RUBY) $(srcdir)/extconf.rb --clean --enable-static
