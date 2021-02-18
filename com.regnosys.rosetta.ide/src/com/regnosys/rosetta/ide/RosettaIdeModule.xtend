/*
 * generated by Xtext 2.24.0
 */
package com.regnosys.rosetta.ide

import com.regnosys.rosetta.generator.RosettaOutputConfigurationProvider
import org.eclipse.xtext.generator.IContextualOutputConfigurationProvider
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider
import com.regnosys.rosetta.ide.hover.RosettaDocumentationProvider

/**
 * Use this class to register ide components.
 */
class RosettaIdeModule extends AbstractRosettaIdeModule {
	
	def Class<? extends IContextualOutputConfigurationProvider> bindIContextualOutputConfigurationProvider() {
		return RosettaOutputConfigurationProvider
	}
	
	
	def Class<? extends IEObjectDocumentationProvider> bindIEObjectDocumentationProvider() {
		return RosettaDocumentationProvider
	}
}