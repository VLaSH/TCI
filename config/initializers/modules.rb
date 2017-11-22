# Initialise modules in /lib
ActiveRecord::Base.send(:include, TheWebFellas::ValidatesAsDateTime,
                                     TheWebFellas::ValidatesAsPostalCode,
                                     TheWebFellas::WasChanged,
                                     Theia::ActsAsAttachable::Model,
                                     Theia::ActsAsCritiqueable::Model,
                                     Theia::ActsAsDeletable,
                                     Theia::ActsAsDiscussable::Model,
                                     Theia::HasDeletableAttachment)

ActionController::Base.send(:include, TheWebFellas::ConfigurablePage,
                                          Theia::ActsAsAttachable::Controller)