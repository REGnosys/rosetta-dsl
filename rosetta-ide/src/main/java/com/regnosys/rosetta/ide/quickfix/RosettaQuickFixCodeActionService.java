package com.regnosys.rosetta.ide.quickfix;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import jakarta.inject.Inject;

import org.eclipse.lsp4j.CodeAction;
import org.eclipse.lsp4j.CodeActionContext;
import org.eclipse.lsp4j.CodeActionKind;
import org.eclipse.lsp4j.CodeActionParams;
import org.eclipse.lsp4j.Command;
import org.eclipse.lsp4j.Diagnostic;
import org.eclipse.lsp4j.jsonrpc.messages.Either;
import org.eclipse.xtext.ide.editor.quickfix.DiagnosticResolution;
import org.eclipse.xtext.ide.editor.quickfix.IQuickFixProvider;
import org.eclipse.xtext.ide.server.ILanguageServerAccess;
import org.eclipse.xtext.ide.server.codeActions.ICodeActionService2;

/*
 * TODO: contribute to Xtext.
 * This is a patch of org.eclipse.xtext.ide.server.codeActions.QuickFixCodeActionService.
 */
public class RosettaQuickFixCodeActionService implements ICodeActionService2 {

	@Inject
	private IQuickFixProvider quickfixes;

	@Override
	public List<Either<Command, CodeAction>> getCodeActions(Options options) {
		boolean handleQuickfixes = options.getCodeActionParams().getContext().getOnly() == null
				|| options.getCodeActionParams().getContext().getOnly().isEmpty()
				|| options.getCodeActionParams().getContext().getOnly().contains(CodeActionKind.QuickFix);
		if (!handleQuickfixes) {
			return Collections.emptyList();
		}

		List<Either<Command, CodeAction>> result = new ArrayList<>();
		for (Diagnostic diagnostic : options.getCodeActionParams().getContext().getDiagnostics()) {
			if (handlesDiagnostic(diagnostic)) {
				result.addAll(options.getLanguageServerAccess()
						.doSyncRead(options.getURI(), (ILanguageServerAccess.Context context) -> {
							options.setDocument(context.getDocument());
							options.setResource(context.getResource());
							Options diagnosticOptions = createOptionsForSingleDiagnostic(options, diagnostic);
							return getCodeActions(diagnosticOptions, diagnostic);
						}));
			}
		}
		return result;
	}
	
	protected boolean handlesDiagnostic(Diagnostic diagnostic) {
		return quickfixes.handlesDiagnostic(diagnostic);
	}
	
	protected List<Either<Command, CodeAction>> getCodeActions(Options options, Diagnostic diagnostic) {
		List<Either<Command, CodeAction>> codeActions = new ArrayList<>();
		
		quickfixes.getResolutions(options, diagnostic).stream()
				.sorted(Comparator
						.nullsLast(Comparator.comparing(DiagnosticResolution::getLabel)))
				.forEach(r -> codeActions.add(Either.forRight(createFix(r, diagnostic))));
		return codeActions;
	}

	private CodeAction createFix(DiagnosticResolution resolution, Diagnostic diagnostic) {
		CodeAction codeAction = new CodeAction();
		codeAction.setDiagnostics(Collections.singletonList(diagnostic));
		codeAction.setTitle(resolution.getLabel());
		codeAction.setEdit(resolution.apply());
		codeAction.setKind(CodeActionKind.QuickFix);

		return codeAction;
	}
	
	private Options createOptionsForSingleDiagnostic(Options base, Diagnostic diagnostic) {
		Options options = new Options();
		options.setCancelIndicator(base.getCancelIndicator());
		options.setDocument(base.getDocument());
		options.setLanguageServerAccess(base.getLanguageServerAccess());
		options.setResource(base.getResource());
		
		CodeActionParams baseParams = base.getCodeActionParams();
		CodeActionContext baseContext = baseParams.getContext();
		CodeActionContext context = new CodeActionContext(List.of(diagnostic), baseContext.getOnly());
		context.setTriggerKind(baseContext.getTriggerKind());
		CodeActionParams params = new CodeActionParams(baseParams.getTextDocument(), diagnostic.getRange(), context);
		
		options.setCodeActionParams(params);
		
		return options;
	}

}