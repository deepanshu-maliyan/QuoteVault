//
//  CollectionDetailView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct CollectionDetailView: View {
    let collection: CollectionWithCount
    
    @StateObject private var viewModel = CollectionsViewModel()
    @StateObject private var collectionsManager = CollectionsManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedQuote: QuoteWithCategory?
    @State private var showQuoteDetail = false
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var editedName: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.collectionQuotes.isEmpty {
                EmptyStateView(
                    icon: "folder",
                    title: "Empty Collection",
                    message: "Add quotes to this collection from the quote details screen"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppSpacing.md) {
                        ForEach(viewModel.collectionQuotes) { quote in
                            QuoteCard(
                                quote: quote,
                                onTap: {
                                    selectedQuote = quote
                                    showQuoteDetail = true
                                }
                            )
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.removeQuoteFromCollection(
                                            quoteId: quote.id,
                                            collectionId: collection.id
                                        )
                                    }
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.md)
                }
            }
        }
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        editedName = collection.name
                        showEditSheet = true
                    } label: {
                        Label("Edit Name", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete Collection", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            await viewModel.loadCollectionQuotes(collectionId: collection.id)
        }
        .navigationDestination(isPresented: $showQuoteDetail) {
            if let quote = selectedQuote {
                QuoteDetailView(quote: quote)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationStack {
                VStack(spacing: AppSpacing.lg) {
                    CustomTextField(
                        placeholder: "Collection name",
                        text: $editedName,
                        icon: "folder"
                    )
                    .padding(.horizontal, AppSpacing.md)
                    
                    PrimaryButton(title: "Save Changes", action: {
                        Task {
                            await collectionsManager.updateCollection(id: collection.id, name: editedName)
                            showEditSheet = false
                        }
                    }, isDisabled: editedName.isEmpty)
                    .padding(.horizontal, AppSpacing.md)
                    
                    Spacer()
                }
                .padding(.top, AppSpacing.lg)
                .navigationTitle("Edit Collection")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showEditSheet = false
                        }
                    }
                }
            }
            .presentationDetents([.height(250)])
        }
        .alert("Delete Collection?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await collectionsManager.deleteCollection(id: collection.id)
                    dismiss()
                }
            }
        } message: {
            Text("This action cannot be undone. All quotes will be removed from this collection.")
        }
    }
}

#Preview {
    NavigationStack {
        CollectionDetailView(
            collection: CollectionWithCount(
                id: UUID(),
                userId: UUID(),
                name: "Morning Motivation",
                coverImageUrl: nil,
                createdAt: "",
                updatedAt: "",
                quoteCount: 5
            )
        )
    }
}
