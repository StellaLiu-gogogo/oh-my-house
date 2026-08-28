import PhotosUI
import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct MemberManagementView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Binding var isPresented: Bool
    @State private var showsAddMember = false

    var body: some View {
        NavigationStack {
            List {
                Section(store.text("在这台设备上切换使用者", "Switch user on this device")) {
                    ForEach(store.members) { member in
                        MemberRow(member: member)
                    }
                }

                Section {
                    Button {
                        showsAddMember = true
                    } label: {
                        Label(store.text("添加家庭成员", "Add Household Member"), systemImage: "person.badge.plus")
                    }
                } footer: {
                    Text(store.text(
                        "成员只属于这个家庭，不需要建立账号。",
                        "Members belong to this household and do not need accounts."
                    ))
                }
            }
            .navigationTitle(store.text("家庭成员", "Household Members"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.text("完成", "Done")) { isPresented = false }
                }
            }
            .sheet(isPresented: $showsAddMember) {
                AddMemberView()
            }
        }
    }
}

private struct MemberRow: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    let member: MemberEntity
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        HStack(spacing: 12) {
            Button {
                store.selectMember(member)
            } label: {
                HStack(spacing: 12) {
                    MemberAvatarView(member: member, size: 44)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(member.name)
                        if store.currentMemberID == member.id {
                            Text(store.text("当前使用者", "Current user"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    if store.currentMemberID == member.id {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .buttonStyle(.plain)

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Image(systemName: "photo")
            }
            .accessibilityLabel(store.text("从相册选择头像", "Choose photo from library"))
        }
        .task(id: selectedPhoto) {
            guard let selectedPhoto,
                  let data = try? await selectedPhoto.loadTransferable(type: Data.self) else { return }
            store.updateAvatar(for: member, data: data)
        }
    }
}

struct MemberAvatarView: View {
    let member: MemberEntity?
    let size: CGFloat

    var body: some View {
        Group {
            if let data = member?.avatarData, let image = platformImage(data: data) {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle().fill(Color(hex: member?.colorHex ?? "4A90E2"))
                    Text(member.map { String($0.name.prefix(1)) } ?? "?")
                        .font(.system(size: size * 0.42, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private func platformImage(data: Data) -> Image? {
#if os(macOS)
        guard let image = NSImage(data: data) else { return nil }
        return Image(nsImage: image)
#else
        guard let image = UIImage(data: data) else { return nil }
        return Image(uiImage: image)
#endif
    }
}

private struct AddMemberView: View {
    @EnvironmentObject private var store: LocalHouseholdDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var colorHex = "4A90E2"

    private let colors = ["4A90E2", "E57373", "81C784", "BA68C8", "FFB74D", "4DB6AC"]

    var body: some View {
        NavigationStack {
            Form {
                TextField(store.text("名字", "Name"), text: $name)
                Section(store.text("颜色", "Color")) {
                    HStack {
                        ForEach(colors, id: \.self) { color in
                            Button {
                                colorHex = color
                            } label: {
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 32, height: 32)
                                    .overlay {
                                        if colorHex == color {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle(store.text("添加家庭成员", "Add Household Member"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.text("取消", "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.text("添加", "Add")) {
                        store.addMember(name: name, colorHex: colorHex)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private extension Color {
    init(hex: String) {
        let value = UInt64(hex, radix: 16) ?? 0x4A90E2
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
