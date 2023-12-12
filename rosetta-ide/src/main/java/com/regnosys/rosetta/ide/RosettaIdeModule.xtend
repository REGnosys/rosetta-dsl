/*
 * generated by Xtext 2.24.0
 */
package com.regnosys.rosetta.ide

import com.regnosys.rosetta.generator.RosettaOutputConfigurationProvider
import org.eclipse.xtext.generator.IContextualOutputConfigurationProvider
import org.eclipse.xtext.documentation.IEObjectDocumentationProvider
import com.regnosys.rosetta.ide.hover.RosettaDocumentationProvider
import com.regnosys.rosetta.ide.inlayhints.IInlayHintsResolver
import com.regnosys.rosetta.ide.inlayhints.RosettaInlayHintsService
import com.regnosys.rosetta.ide.inlayhints.IInlayHintsService
import com.regnosys.rosetta.ide.util.RangeUtils
import com.regnosys.rosetta.ide.semantictokens.ISemanticTokenTypesProvider
import com.regnosys.rosetta.ide.semantictokens.ISemanticTokenModifiersProvider
import com.regnosys.rosetta.ide.semantictokens.ISemanticTokensService
import com.regnosys.rosetta.ide.semantictokens.RosettaSemanticTokensService
import com.regnosys.rosetta.ide.semantictokens.RosettaSemanticTokenTypesProvider
import com.regnosys.rosetta.ide.textmate.RosettaTextMateGrammarUtil
import org.eclipse.xtext.ide.server.formatting.FormattingService
import com.regnosys.rosetta.ide.formatting.RosettaFormattingService
import org.eclipse.xtext.ide.editor.quickfix.IQuickFixProvider
import com.regnosys.rosetta.ide.quickfix.RosettaQuickFixProvider
import org.eclipse.xtext.ide.server.codeActions.ICodeActionService2
import com.regnosys.rosetta.ide.quickfix.RosettaQuickFixCodeActionService
import org.eclipse.xtext.ide.server.contentassist.ContentAssistService
import org.eclipse.xtext.service.OperationCanceledManager
import com.regnosys.rosetta.ide.contentassist.cancellable.ICancellableContentAssistParser
import com.regnosys.rosetta.ide.contentassist.cancellable.CancellableRosettaParser
import com.regnosys.rosetta.ide.contentassist.cancellable.CancellableContentAssistService
import com.regnosys.rosetta.ide.contentassist.cancellable.RosettaOperationCanceledManager
import com.regnosys.rosetta.ide.semantictokens.RosettaSemanticTokenModifiersProvider

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
	
	def Class<? extends RangeUtils> bindRangeUtils() {
		RangeUtils
	}
	
	def Class<? extends IInlayHintsResolver> bindIInlayHintsResolver() {
		RosettaInlayHintsService
	}
	
	def Class<? extends IInlayHintsService> bindIInlayHintsService() {
		RosettaInlayHintsService
	}
	
	def Class<? extends ISemanticTokenTypesProvider> bindISemanticTokenTypesProvider() {
		RosettaSemanticTokenTypesProvider
	}
	
	def Class<? extends ISemanticTokenModifiersProvider> bindISemanticTokenModifiersProvider() {
		RosettaSemanticTokenModifiersProvider
	}
	
	def Class<? extends ISemanticTokensService> bindISemanticTokensService() {
		RosettaSemanticTokensService
	}
	
	def Class<? extends RosettaTextMateGrammarUtil> bindRosettaTextMateGrammarUtil() {
		RosettaTextMateGrammarUtil
	}

	def Class<? extends FormattingService> bindFormattingService() {
		RosettaFormattingService
	}
	
	def Class<? extends IQuickFixProvider> bindIQuickFixProvider() {
		RosettaQuickFixProvider
	}
	
	def Class<? extends ICodeActionService2> bindICodeActionService2() {
		RosettaQuickFixCodeActionService
	}
	
	def Class<? extends ICancellableContentAssistParser> bindICancellableContentAssistParser() {
		CancellableRosettaParser
	}
	
	def Class<? extends ContentAssistService> bindContentAssistService() {
		CancellableContentAssistService
	}
	
	def Class<? extends OperationCanceledManager> bindOperationCanceledManager() {
		RosettaOperationCanceledManager
	}
}
